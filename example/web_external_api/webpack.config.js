const path = require('path');

module.exports = {
    entry: './src/index.ts', // 入口文件改为 TypeScript 文件
    output: {
        filename: 'meeting_external_api.js',
        path: path.resolve(__dirname, 'dist'),
        library: 'MeetExternalAPI',
        libraryTarget: 'umd',
    },
    resolve: {
        extensions: ['.ts', '.js'], // 支持的文件扩展名
    },
    module: {
        rules: [
            {
                test: /\.ts$/, // 匹配 .ts 文件
                use: 'ts-loader', // 使用 ts-loader
                exclude: /node_modules/, // 排除 node_modules
            },
        ],
    },
    mode: 'development',
};
