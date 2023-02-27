// Copyright (c) Microsoft. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for full license information.

#ifndef _ARLOGGER_H_
#define _ARLOGGER_H_

#ifdef __cplusplus
extern "C"
{
#endif

/*Public API*/
void ArLoggerResetError();
char ArLoggerGetError();
unsigned long ArLoggerGetErrorCounter();
unsigned long ArLoggerInit();

void ArLogError(const char *format, ...);
void ArLogInfo(const char *format, ...);

#define LOG(...)
#define LogInfo(...)
#define LogBinary(...)
#define LogError(...)
#define LogLastError(...)
#define xlogging_get_log_function() NULL
#define xlogging_set_log_function(...)
#define LogErrorWinHTTPWithGetLastErrorAsString(...)
#define UNUSED(x) (void)(x)
#ifdef __cplusplus
}
#endif

#endif