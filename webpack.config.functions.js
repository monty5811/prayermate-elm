const path = require('path');
const webpack = require("webpack");

if (process.env.WATCH) {
  elmLoader = 'elm-webpack-loader?debug=true';
} else {
  elmLoader = 'elm-webpack-loader';
}

module.exports = {
  entry: {csv: './src/csv.js'},
  target: 'node',
  module: {
    rules: [
      { test: /\.js$/, exclude: /node_modules/, loader: "babel-loader" },
      {
        test: /\.html$/,
        exclude: /node_modules/,
        loader: 'file-loader?name=[name].[ext]',
      },
      {
        test: /\.jpe?g$|\.gif$|\.png$|\.svg$|\.woff$|\.ttf$|\.json$|\.md$|\.wav$|\.mp3|\.ico$/,
        exclude: /node_modules/,
        loader: "file-loader?name=[name].[ext]",
      },
      {
        test: /\.elm$/,
        exclude: [/elm-stuff/, /node_modules/],
        loader: elmLoader,
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
    filename: '[name].js',
    libraryTarget: 'commonjs',
    path: path.resolve(__dirname, 'functions')
  },
  devServer: {
    inline: false,
    stats: { colors: true },
    port: 4002,
    disableHostCheck: true,
    hot: true,
    contentBase: path.join(__dirname, "functions"),
    historyApiFallback: true,
  },
};
