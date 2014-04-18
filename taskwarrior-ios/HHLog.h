#ifndef __HHLOG_H__
#define __HHLOG_H__

#import <CocoaLumberjack/DDLog.h>

// BASE_LOG and BASE_TRACE should only be used to define other loggers, not called directly.
#define BASE_LOG(logger, ...) logger(@"-[%@(0x%tx) %@] %@", NSStringFromClass([self class]), self, NSStringFromSelector(_cmd), [NSString stringWithFormat:__VA_ARGS__])
#define BASE_TRACE(logger)  logger(@"-[%@(0x%tx) %@]", NSStringFromClass([self class]), self, NSStringFromSelector(_cmd))

#define HHLogError(...) BASE_LOG(DDLogError, __VA_ARGS__)
#define HHLogWarn(...) BASE_LOG(DDLogWarn, __VA_ARGS__)
#define HHLogDebug(...) BASE_LOG(DDLogDebug, __VA_ARGS__)
#define HHLogInfo(...) BASE_LOG(DDLogInfo, __VA_ARGS__)
#define HHLogVerbose(...) BASE_LOG(DDLogVerbose, __VA_ARGS__)
#define HHLogTrace() BASE_TRACE(DDLogInfo)

#endif // __HHLOG_H__

extern const int ddLogLevel;

