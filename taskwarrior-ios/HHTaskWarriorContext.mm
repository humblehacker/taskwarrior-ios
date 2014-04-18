//
//  HHTaskWarriorContext
//  taskwarrior-ios
//
//  Created by david on 4/19/14.
//  Copyright 2014 David Whetstone. All rights reserved.
//

#include <task/Context.h>
#include <iostream>
#include <sstream>
#import "HHLog.h"
#import "HHTaskWarriorContext.h"
#import "HHTaskFile.h"
#include "OutputStringBuf.h"

Context context;

typedef std::unique_ptr<char const *[]> SafeArgv;

@interface HHTaskWarriorContext ()
@property (nonatomic, strong, readonly) NSURL *_homeDir;
@property (nonatomic, strong) dispatch_queue_t processingQueue;
@end

@interface HHTaskFile (Friend)
- (id)initWithTF2:(TF2 *)tf2;
@end

@implementation HHTaskWarriorContext
{
    std::unique_ptr<InputStringBuf> _cinBuffer;
    std::unique_ptr<OutputStringBuf> _coutBuffer;
    std::unique_ptr<OutputStringBuf> _cerrBuffer;
    std::streambuf *_prevCoutBuffer;
    std::streambuf *_prevCerrBuffer;
    std::streambuf *_prevCinBuffer;
}

- (CGSize)terminalSize
{
    return CGSizeMake(context.config.getInteger("defaultwidth"),
            context.config.getInteger("defaultheight"));
}

- (void)setTerminalSize:(CGSize)terminalSize
{
    HHLogInfo(@"terminalSize:%@", NSStringFromCGSize(terminalSize));
    context.config.set("defaultwidth", terminalSize.width);
    context.config.set("defaultheight", terminalSize.height);
}

+ (instancetype)sharedContext
{
    static HHTaskWarriorContext *context;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^
    {
        context = [[self alloc] init];
    });

    return context;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        self.processingQueue = dispatch_queue_create("contextProcessingQueue", (dispatch_queue_attr_t)DISPATCH_QUEUE_SERIAL);
        [self _createHomeDirectory];
        [self _installTaskRCFile];
        [self _updateStandardStreamsWhenNotified];
    }

    return self;
}


+ (void)_createDirectoryAtURL:(NSURL *)url error:(NSError **)error
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:url.path])
    {
        [fileManager createDirectoryAtPath:url.path
               withIntermediateDirectories:YES attributes:nil error:error];
    }
}

- (void)_createHomeDirectory
{
    NSError *error;
    [[self class] _createDirectoryAtURL:self._homeDir error:&error];
    setenv("HOME", self._homeDir.relativePath.UTF8String, 1);
}

- (void)_installTaskRCFile
{
    NSURL *appDir = [NSURL fileURLWithPath:[[NSBundle mainBundle] resourcePath]];
    NSURL *source = [appDir URLByAppendingPathComponent:@".taskrc"];
    NSURL *dest   = [self._homeDir URLByAppendingPathComponent:@".taskrc"];

    HHLogInfo(@"Copying: %@", source);
    HHLogInfo(@"To:      %@", dest);

    NSError *error = nil;
    [self _replaceFileAtURL:source withFileAtURL:dest error:&error];
    if (error)
        HHLogError(@"Failed to replace file: %@", error.localizedDescription);
}

- (NSString *)_replaceFileAtURL:(NSURL *)source withFileAtURL:(NSURL *)dest error:(NSError **)error
{
    NSFileManager *manager = [NSFileManager defaultManager];

    NSString *path = dest.relativePath;

    if ([manager fileExistsAtPath:path])
    {
        [manager removeItemAtURL:dest error:error];

        if (*error)
            return nil;
    }

    [manager copyItemAtURL:source toURL:dest error:error];

    return path;
}

- (NSURL *)_homeDir
{
    static NSURL *homeDir;
    static dispatch_once_t predicate;

    dispatch_once(&predicate, ^
    {
        NSError *error = nil;
        homeDir = [[NSFileManager defaultManager] URLForDirectory:NSApplicationSupportDirectory
                                                         inDomain:NSUserDomainMask
                                                appropriateForURL:nil
                                                           create:YES
                                                            error:&error];
        if (error)
            HHLogError(@"Failed to retrieve home directory:%@", error.localizedDescription);
    });

    return homeDir;
}

- (void)_updateStandardStreamsWhenNotified
{
    [[NSNotificationCenter defaultCenter] addObserverForName:ProcessStandardOutputNotification
                                                      object:nil
                                                       queue:nullptr
                                                  usingBlock:^(NSNotification *n)
            {
                HHLogInfo(@"StringBuf:%tx", [n.object pointerValue]);
                // Called on main thread

                NSString *outputText;
                NSString *errorText;

                [self _readStdOut:&outputText stdErr:&errorText];
                HHLogInfo(@"syncing stdout:%@ stderr:%@", outputText, errorText);
                self.updateStandardStreams(outputText, errorText);
            }];
}

- (void)processInputText:(NSString *)inputText completion:(ProcessCompletionBlock)completion
{
    // If task is waiting for a response, handle that.
    if (_cinBuffer.get() && _cinBuffer->_waiting_for_input)
    {
        _cinBuffer->set_str(std::string(inputText.UTF8String));
        return;
    }

    // Prepend 'task' so the user doesn't have to.
    if (![inputText hasPrefix:@"task"])
        inputText = [@"task " stringByAppendingString:inputText];

    dispatch_async(self.processingQueue, ^
    {
        NSArray *tokens = [inputText componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        [self _processTokens:tokens completion:completion];
    });
}

- (void)_processTokens:(NSArray *)tokens completion:(ProcessCompletionBlock)completion
{
    [self _resetContext];
    [self _redirectStandardStreams];

    SafeArgv argv = [self _argvFromTokenArray:tokens];

    try
    {
        context.initialize(tokens.count, argv.get());
        [self _applyConfigurationOverrides];
        context.run();

    }
    catch (const std::exception &e)
    {
        HHLogError(@"Exception occurred: %s", e.what());
    }

    NSString *outputText;
    NSString *errorText;

    [self _readStdOut:&outputText stdErr:&errorText];
    [self _resetStandardStreams];

    dispatch_async(dispatch_get_main_queue(), ^
    {
        if (completion)
            completion(outputText, errorText);
    });
}

- (void)_redirectStandardStreams
{
    try
    {
        _cinBuffer.reset(new InputStringBuf());
        _coutBuffer.reset(new OutputStringBuf());
        _cerrBuffer.reset(new OutputStringBuf());

        _prevCinBuffer  = std::cin.rdbuf(_cinBuffer.get());
        _prevCoutBuffer = std::cout.rdbuf(_coutBuffer.get());
        _prevCerrBuffer = std::cerr.rdbuf(_cerrBuffer.get());
    }
    catch (std::exception const &e)
    {
        HHLogError(@"Exception occurred: %s", e.what());
    }
}

- (void)_resetStandardStreams
{
    try
    {
        if (_prevCinBuffer)
        {
            std::cin.rdbuf(_prevCinBuffer);
            _prevCinBuffer = nullptr;
        }

        if (_prevCoutBuffer)
        {
            std::cout.rdbuf(_prevCoutBuffer);
            _prevCoutBuffer = nullptr;
        }

        if (_prevCerrBuffer)
        {
            std::cerr.rdbuf(_prevCerrBuffer);
            _prevCerrBuffer = nullptr;
        }

        _cinBuffer.release();
        _coutBuffer.release();
        _cerrBuffer.release();
    }
    catch (std::exception const &e)
    {
        HHLogError(@"Exception occurred: %s", e.what());
    }
}

- (void)_readStdOut:(NSString **)stdOutText stdErr:(NSString **)stdErrText
{
    std::string outputString;
    if (_coutBuffer.get())
    {
        outputString = _coutBuffer->str();
        _coutBuffer->str("");
    }

    std::string errorString;
    if (_cerrBuffer.get())
    {
        errorString = _cerrBuffer->str();
        _cerrBuffer->str("");
    }

    HHLogInfo(@"out:%s err:%s", outputString.c_str(), errorString.c_str());

    *stdOutText = [NSString stringWithUTF8String:outputString.c_str()];
    *stdErrText = [NSString stringWithUTF8String:errorString.c_str()];
}

- (SafeArgv)_argvFromTokenArray:(NSArray *)tokens
{
    SafeArgv argv(new char const *[tokens.count]);

    for (NSUInteger i = 0; i < tokens.count; ++i)
        argv[i] = [tokens[i] UTF8String];

    return argv;
}

- (void)_resetContext
{
    // destroy the old context, retaining its memory space
    context.~Context();

    // initialize the new context in-place
    new(&context) Context();
}

- (void)_applyConfigurationOverrides
{
    // Turn off terminal size detection
    context.config.set("detection", "off");

    // Force ANSI coloring
    context.config.set("_forcecolor", "on");
    context.determine_color_use = true;
}

- (HHTaskFile *)pendingTasks
{
    return [[HHTaskFile alloc] initWithTF2:&context.tdb2.pending];
}

- (HHTaskFile *)completedTasks
{
    return [[HHTaskFile alloc] initWithTF2:&context.tdb2.completed];
}

- (HHTaskFile *)undoTasks
{
    return [[HHTaskFile alloc] initWithTF2:&context.tdb2.undo];
}

- (HHTaskFile *)backlogTasks
{
    return [[HHTaskFile alloc] initWithTF2:&context.tdb2.backlog];
}

@end
