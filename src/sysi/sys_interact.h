#pragma once

#include <stdbool.h>
#include <stdint.h>
#include <inttypes.h>
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <limits.h>
#include <ctype.h>
#include <stddef.h>

static inline bool __read_sysfs_v(const char *path, char *buffer, size_t size) {
    if (path == NULL || buffer == NULL || size < 2) return false;

    FILE *fp = fopen(path, "r");
    if (fp == NULL) return false;

    size_t length = 0;
    bool ok = true;
    int ch;
    while ((ch = fgetc(fp)) != EOF) {
        if (ch == '\0' || length + 1 >= size) {
            ok = false;
            break;
        }
        buffer[length++] = (char)ch;
    }

    if (ferror(fp)) ok = false;
    if (fclose(fp) != 0) ok = false;
    if (!ok) return false;

    buffer[length] = '\0';
    return ok;
}

#define DEFINE_SYSFS_SIGNED(name, type, min_val, max_val)       \
    static inline bool __read_sysfs_##name(                     \
        const char *path, type *out)                            \
    {                                                           \
        char buffer[128];                                       \
        if (!out || !__read_sysfs_v(path, buffer,            \
                                        sizeof buffer))         \
            return false;                                       \
                                                                \
        char *end;                                              \
        errno = 0;                                              \
        intmax_t value = strtoimax(buffer, &end, 10);           \
                                                                \
        while (isspace((unsigned char)*end)) ++end;             \
        if (errno == ERANGE || end == buffer || *end != '\0' || \
            value < (intmax_t)(min_val) ||                      \
            value > (intmax_t)(max_val))                        \
            return false;                                       \
                                                                \
        *out = (type)value;                                     \
        return true;                                            \
    }

#define DEFINE_SYSFS_UNSIGNED(name, type, max_val)              \
    static inline bool __read_sysfs_##name(                     \
        const char *path, type *out)                            \
    {                                                           \
        char buffer[128];                                       \
        if (!out || !__read_sysfs_v(path, buffer,            \
                                        sizeof buffer))         \
            return false;                                       \
                                                                \
        char *start = buffer;                                   \
        while (isspace((unsigned char)*start)) ++start;         \
        if (*start == '-')                                      \
            return false;                                       \
                                                                \
        char *end;                                              \
        errno = 0;                                              \
        uintmax_t value = strtoumax(start, &end, 10);           \
                                                                \
        while (isspace((unsigned char)*end)) ++end;             \
        if (errno == ERANGE || end == start || *end != '\0' ||  \
            value > (uintmax_t)(max_val))                       \
            return false;                                       \
                                                                \
        *out = (type)value;                                     \
        return true;                                            \
    }

