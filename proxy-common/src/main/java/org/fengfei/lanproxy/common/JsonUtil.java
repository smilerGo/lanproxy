package org.fengfei.lanproxy.common;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

/**
 * JSON与POJO转换工具类.
 *
 * @author fengfei
 *
 */
public class JsonUtil {
    private static final Gson DEFAULT_GSON = new Gson();

    /**
     * 将JSON字符串转换为对象
     *
     * @param jsonString JSON字符串
     * @param typeToken  要转换的对象类型
     * @return 转换后的对象
     */
    @SuppressWarnings("unchecked")
    public static <T> T json2Object(String jsonString, TypeToken<T> typeToken) {
        try {
            return (T) DEFAULT_GSON.fromJson(jsonString, typeToken.getType());
        } catch (Exception ignored) {}
        return null;
    }


    /**
     * 将对象转换为JSON字符串
     *
     * @param obj 要转换的对象
     * @return 转换后的JSON字符串
     */
    public static String object2Json(Object obj) {
        return DEFAULT_GSON.toJson(obj);
    }


    /**
     * 获取JsonMap对象
     *
     * @return Gson对象
     */
    public static Gson getJsonMap() {
        return DEFAULT_GSON;
    }


}