package com.aoeiuv020.meeting_flutter.util

import com.google.gson.Gson
import com.google.gson.GsonBuilder
import com.google.gson.reflect.TypeToken
import java.lang.reflect.Type

/**
 * Created by AoEiuV020 on 2018.09.24-14:26:47.
 */
object GsonUtils {
    val gsonBuilder: GsonBuilder
        get() = GsonBuilder()
    val gson: Gson = gsonBuilder
        .create()
}

fun Any?.toJson(gson: Gson): String = gson.toJson(this)
fun Any?.toJson(): String = GsonUtils.gson.toJson(this)

// reified T 可以直接给gson用，没有reified的T用TypeToken包装也没用，只能传入type,
inline fun <reified T> type(): Type = object : TypeToken<T>() {}.type

inline fun <reified T> String.toBean(gson: Gson): T = toBean(gson, type<T>())
inline fun <reified T> String.toBean(): T = toBean(GsonUtils.gson, type<T>())
fun <T> String.toBean(gson: Gson, type: Type): T = gson.fromJson<T>(this, type)

inline fun <reified T> String.toNullableBean(gson: Gson): T? = toNullableBean(gson, type<T>())
inline fun <reified T> String.toNullableBean(): T? = toNullableBean(GsonUtils.gson, type<T>())
fun <T> String.toNullableBean(gson: Gson, type: Type): T? = gson.fromJson<T>(this, type)

