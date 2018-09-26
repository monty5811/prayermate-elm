const path = require('path');
const webpack = require("webpack");
const HtmlWebpackPlugin = require('html-webpack-plugin');
const UglifyJsPlugin = require('uglifyjs-webpack-plugin');

plugins = [
  new HtmlWebpackPlugin(
    {
      title: 'unofficial prayermate',
      template: 'src/index.tmpl',
    }
  ),
]

if (process.env.WATCH) {
  elmDebug = true;
  elmOpt = false;
} else {
  elmDebug = false;
  elmOpt = true;
}

new UglifyJsPlugin({
  uglifyOptions: {
    warnings: false,
    parse: {},
    compress: {},
    mangle: true, // Note `mangle.properties` is `false` by default.
    output: null,
    toplevel: false,
    nameCache: null,
    ie8: false,
    keep_fnames: false,
  }
})

module.exports = {
  entry: [
    './src/index.js',
  ],
  plugins: plugins,
  module: {
    rules: [
      {
        test: /\.jpe?g$|\.gif$|\.png$|\.svg$|\.woff$|\.ttf$|\.md$|\.wav$|\.mp3|\.ico$/,
        exclude: /node_modules/,
        loader: "file-loader",
        options: {
          name: '[name].[ext]'
        } ,
      },
      {
        test: /\.elm$/,
        exclude: [/elm-stuff/, /node_modules/],
        loader: 'elm-webpack-loader',
        options: {
          debug: elmDebug,
          optimize: elmOpt,
        }
      },
      {
        test: /\.css/,
        use: [
          { loader: "style-loader" },
          { loader: "css-loader" }
        ]
      },
    ],
    noParse: /\.elm$/,
  },
  output: {
    filename: 'bundle.[contenthash].js',
    path: path.resolve(__dirname, 'public')
  },
    optimization: {
        minimizer: [
        new UglifyJsPlugin({
          uglifyOptions: {
            warnings: false,
            parse: {},
            compress: {
                pure_funcs: "F2,F3,F4,F5,F6,F7,F8,F9,A2,A3,A4,A5,A6,A7,A8,A9",
                pure_getters: true,
                keep_fargs: false,
                unsafe_comps: true,
                unsafe: true
            },
            mangle: false,
            output: null,
            toplevel: false,
            nameCache: null,
            ie8: false,
            keep_fnames: false,
          }}),
        new UglifyJsPlugin({
          uglifyOptions: {
            warnings: false,
            parse: {},
            compress: {},
            mangle: true,
            output: null,
            toplevel: false,
            nameCache: null,
            ie8: false,
            keep_fnames: false,
          }})
    ]
  },
  devServer: {
    inline: false,
    stats: { colors: true },
    port: 4001,
    disableHostCheck: true,
    hot: true,
    contentBase: path.join(__dirname, "public"),
    historyApiFallback: true,
  },
  performance: {
    hints: false
  },
};
