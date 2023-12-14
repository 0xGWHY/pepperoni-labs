const webpack = require("webpack");

module.exports = function override(config, env) {
  config.resolve.fallback = {
    ...config.resolve.fallback, // 기존의 fallback 설정을 유지
    crypto: require.resolve("crypto-browserify"),
    stream: require.resolve("stream-browserify"),
    url: require.resolve("url"),
    https: require.resolve("https-browserify"),
    http: require.resolve("stream-http"),
    zlib: require.resolve("browserify-zlib"),
    buffer: require.resolve("buffer/"),
  };

  config.plugins = [
    ...config.plugins,
    new webpack.ProvidePlugin({
      Buffer: ["buffer", "Buffer"],
      process: "process/browser", // 이미 있을 경우 이 줄은 생략
    }),
  ];

  config.plugins = [
    ...config.plugins,
    new webpack.ProvidePlugin({
      process: "process/browser", // process 모듈을 추가합니다.
    }),
  ];

  return config;
};
