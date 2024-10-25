package com.aoeiuv020.meeting_flutter.util

import com.google.gson.Gson
import java.lang.reflect.Type

object JsonUtil {
    internal val gson: Gson by lazy { GsonUtils.gson }

    @JvmStatic
    fun toJson(obj: Any): String {
        return gson.toJson(obj)
    }

    @JvmStatic
    fun <T> toBean(json: String, clazz: Class<T>): T {
        return gson.fromJson(json, clazz)
    }

    @JvmStatic
    fun <T> toBean(json: String, type: Type): T {
        return gson.fromJson(json, type)
    }
}