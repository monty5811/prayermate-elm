const path = require('path');
const webpack = require("webpack");
const HtmlWebpackPlugin = require('html-webpack-plugin');
const WorkboxPlugin = require('workbox-webpack-plugin');

defaultPlugins = [
  new HtmlWebpackPlugin(
    {
      title: 'unofficial prayermate',
      template: 'src/index.tmpl',
    }
  ),
]

if (process.env.WATCH) {
  elmLoader = 'elm-webpack-loader?debug=true';
  plugins = defaultPlugins;
} else {
  elmLoader = 'elm-webpack-loader';
  plugins = defaultPlugins.concat([
    new WorkboxPlugin.GenerateSW({
      globDirectory: './public',
      globPatterns: ['**/*.{html,js,json}'],
      swDest: 'sw.js',
      clientsClaim: true,
      skipWaiting: true,
      handler: 'networkFirst',
    }),
  ]);
}

module.exports = {
  entry: './src/index.js',
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
    filename: 'bundle.[contenthash].js',
    path: path.resolve(__dirname, 'public')
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
