package org.fengfei.lanproxy.server.config.web;

import java.net.URI;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

import org.fengfei.lanproxy.server.config.web.exception.ContextException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import io.netty.handler.codec.http.FullHttpRequest;

/**
 * 接口路由管理
 *
 * @author fengfei
 *
 */
public class ApiRoute {

    private static final Logger logger = LoggerFactory.getLogger(ApiRoute.class);

    /** 接口路由 */
    private static final Map<String, RequestHandler> routes = new ConcurrentHashMap<>();

    /** 拦截器，初始化后不会在变化 */
    private static final List<RequestMiddleware> middlewares = new ArrayList<>();


    /**
     * 添加路由
     * @param uri 路由路径
     * @param requestHandler 请求处理程序
     * @throws IllegalArgumentException 如果存在重复的路径
     */
    public static void addRoute(String uri, RequestHandler requestHandler) {
        if (routes.containsKey(uri)) {
            throw new IllegalArgumentException("Duplicate uri:" + uri);
        }

        logger.info("Add route: {}", uri);
        routes.put(uri, requestHandler);
    }



    /**
     * 添加请求中间件
     * @param requestMiddleware 请求中间件实例
     * @throws IllegalArgumentException 如果请求中间件已经存在
     */
    public static void addMiddleware(RequestMiddleware requestMiddleware) {
        if (middlewares.contains(requestMiddleware)) {
            throw new IllegalArgumentException("重复的请求中间件实例：" + requestMiddleware);
        }

        logger.info("添加请求中间件：{}", requestMiddleware);
        middlewares.add(requestMiddleware);
    }



        public static ResponseInfo run(FullHttpRequest request) {
        try {
            // 预处理请求，执行拦截器
            for (RequestMiddleware middleware : middlewares) {
                middleware.preRequest(request);
            }

            // 解析请求的URI
            URI uri = new URI(request.getUri());

            // 获取请求处理程序
            RequestHandler handler = routes.get(uri.getPath());

            // 初始化响应信息
            ResponseInfo responseInfo = null;

            // 处理请求
            if (handler != null) {
                responseInfo = handler.request(request);
            } else {
                // 如果请求处理程序不存在，则返回错误响应信息
                responseInfo = ResponseInfo.build(ResponseInfo.CODE_API_NOT_FOUND, "api not found");
            }

            // 返回响应信息
            return responseInfo;
        } catch (Exception ex) {
            if (ex instanceof ContextException) {
                // 如果异常是ContextException类型，则返回错误响应信息
                return ResponseInfo.build(((ContextException) ex).getCode(), ex.getMessage());
            }

            // 记录异常日志
            logger.error("request error", ex);
        }

        // 发生错误，返回空响应信息
        return null;
    }

}
