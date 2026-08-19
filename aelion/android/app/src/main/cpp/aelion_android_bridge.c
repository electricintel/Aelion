#include <jni.h>
#include <stdio.h>
#include <string.h>
#include "usp.h"
#include "bus.h"
#include "registry.h"

JNIEXPORT jstring JNICALL
Java_io_aelion_app_MainActivity_nativeStatus(JNIEnv* env, jobject thiz) {
    (void)thiz;
    return (*env)->NewStringUTF(env, "Aelion Android Preview Ready");
}

JNIEXPORT jstring JNICALL
Java_io_aelion_app_MainActivity_nativeDetails(JNIEnv* env, jobject thiz) {
    (void)thiz;
    return (*env)->NewStringUTF(
        env,
        "Native bridge is active with core USP parse, registry, and bus routing enabled."
    );
}

JNIEXPORT jstring JNICALL
Java_io_aelion_app_MainActivity_nativeExecuteCommand(
    JNIEnv* env,
    jobject thiz,
    jstring command
) {
    const char* raw;
    Sentence sentence;
    EngineRecord health;
    char serialized[512];
    char response[1024];

    (void)thiz;
    if (command == NULL) {
        return (*env)->NewStringUTF(env, "Command cannot be empty.");
    }

    raw = (*env)->GetStringUTFChars(env, command, 0);
    if (raw == NULL || raw[0] == '\0') {
        if (raw != NULL) {
            (*env)->ReleaseStringUTFChars(env, command, raw);
        }
        return (*env)->NewStringUTF(env, "Command cannot be empty.");
    }

    sentence = usp_parse(raw);
    bus_publish(&sentence);
    bus_route(&sentence);

    if (sentence.target_engine[0] != '\0') {
        registry_register(sentence.target_engine);
        health = registry_health(sentence.target_engine);
    } else {
        registry_register("core");
        health = registry_health("core");
    }

    usp_serialize(&sentence, serialized);
    snprintf(
        response,
        sizeof(response),
        "input: %s\nengine: %s\nhealthy: %d\nserialized: %s",
        raw,
        health.engine_name,
        health.healthy,
        serialized
    );

    (*env)->ReleaseStringUTFChars(env, command, raw);
    return (*env)->NewStringUTF(env, response);
}
