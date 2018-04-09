const path = require('path');
const webpack = require("webpack");
const CleanWebpackPlugin = require('clean-webpack-plugin');
const HtmlWebpackPlugin = require('html-webpack-plugin');
const workboxPlugin = require('workbox-webpack-plugin');

defaultPlugins = [
  new CleanWebpackPlugin(['public']),
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
    new webpack.optimize.UglifyJsPlugin({
      compress: {
        warnings: false
      }
    }),
    new workboxPlugin({
      globDirectory: './public',
      globPatterns: ['**/*.{html,js}'],
      swDest: path.join('./public', 'sw.js'),
      clientsClaim: true,
      skipWaiting: true,
    }),
  ]);
}

module.exports = {
  entry: './src/index.js',
  plugins: plugins,
  module: {
    loaders: [
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
    filename: 'bundle.[hash].js',
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
};
