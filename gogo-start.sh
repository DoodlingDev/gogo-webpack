#!/bin/bash
#
# Sometimes you just want to start banging out a quick project
# or POC and you don't care about the config. It's not going
# to last, it's for trying things out.
#
# But you need es6+ or imports or bundles or dev servers... and
# you don't want to spend time setting up webpack for your basic
# needs.
#
# GOGO webpack's got your back.
#
# Go Go Webpack!

BLACK=$(tput setaf 0)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
LIME_YELLOW=$(tput setaf 190)
POWDER_BLUE=$(tput setaf 153)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
WHITE=$(tput setaf 7)
NORMAL=$(tput sgr0)

clear
echo ''
echo ' _______  _______  __     _______  _______  __'
echo '|       ||       ||  |   |       ||       ||  |'
echo '|    ___||   _   ||  |   |    ___||   _   ||  |'
echo '|   | __ |  | |  ||  |   |   | __ |  | |  ||  |'
echo '|   ||  ||  |_|  ||__|   |   ||  ||  |_|  ||__|'
echo '|   |_| ||       | __    |   |_| ||       | __ '
echo '|_______||_______||__|   |_______||_______||__|'
echo '     _     _  _______  _______  _______  _______  _______  ___   _  __'
echo '    | | _ | ||       ||  _    ||       ||   _   ||       ||   | | ||  |'
echo '    | || || ||    ___|| |_|   ||    _  ||  |_|  ||       ||   |_| ||  |'
echo '    |       ||   |___ |       ||   |_| ||       ||       ||      _||  |'
echo '    |       ||    ___||  _   | |    ___||       ||      _||     |_ |__|'
echo '    |   _   ||   |___ | |_|   ||   |    |   _   ||     |_ |    _  | __ '
echo '    |__| |__||_______||_______||___|    |__| |__||_______||___| |_||__|'
echo ""
echo ""

mkdir ./$1
cd ./$1

# create minimal propject.json
printf 'Initializing Project with package.json...'
cat << EOT >> package.json
{
  "name": "$1",
  "version": "0.1.0",
  "scripts": {
    "start": "yarn webpack-dev-server --config webpack.config.development.js",
    "test": "mocha"
  }
}
EOT
printf "${GREEN}done!${NORMAL}\n\n"

printf "Creating project .rc files..."
cat << EOT >> .babelrc
{
  "presets": ["env", "flow", "es2015"],
  "plugins": [
    "transform-object-rest-spread",
    "transform-class-properties",
  ]
}
EOT

cat << EOT >> .eslintrc.js
module.exports = {
  "extends": [
    "google"
  ],
  "parser": "babel-eslint",
  "env": {
    "browser": true,
    "node": true,
    "es6": true
  },
  "parserOptions": {
    "ecmaVersion": 6,
    "sourceType": "module",
    "ecmaFeatures": {
      "impliedStrict": true
    },
  },
  "rules": {
    "no-multi-spaces": "off",
    "quotes": ["error", "double"],
    "one-var": "off"
  },
};
EOT
printf "${GREEN}done!${NORMAL}\n\n"

printf "${NORMAL}Creating Webpack Config..."
cat << EOT >> webpack.config.development.js
const path = require("path"),
  HtmlWebpackPlugin = require("html-webpack-plugin"),
  HtmlWebpackPluginConfig = new HtmlWebpackPlugin({
    template: "index.html",
    filename: "index.html",
    inject: "body"
  });

module.exports = {
  entry: ["babel-polyfill", "index.js"],
  target: "web",
  output: {
    filename: "bundle.js",
    path: path.resolve(__dirname, "lib")
  },
  module: {
    loaders: [
      {
        test: /.js/,
        loader: "babel-loader",
        exclude: /node_modules/,
      },
    ],
  },
  devServer: {
    watchOptions: {
      aggregateTimeout: 600,
      poll: 1000,
      ignored: /node_modules/,
    },
  },
  plugins: [HtmlWebpackPluginConfig],
  resolve: {
    modules: [path.resolve("./"), path.resolve("./node_modules")],
  },
};
EOT

printf "${GREEN}done!${NORMAL}"
printf "\n\n"

printf "Generating index.html..."
cat << EOT >> index.html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta http-equiv="x-ua-compatible" content="ie=edge">
    <title>$1</title>
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
  </head>
  <body>
    <!--[if lte IE 9]>
      <p class="browserupgrade">You are using an <strong>outdated</strong> browser. Please <a href="https://browsehappy.com/">upgrade your browser</a> to improve your experience and security.</p>
    <![endif]-->
    Hello, World!
  </body>
</html>
EOT

printf "${GREEN}done!${NORMAL}"
printf "\n\n"

DEV_DEPENDENCIES=( "babel-cli" "babel-core" "babel-eslint" "babel-loader" "babel-plugin-transform-class-properties" "babel-plugin-transform-object-rest-spread" "babel-polyfill" "babel-preset-env" "babel-preset-es2015" "babel-preset-flow" "babel-preset-react" "eslint" "eslint-config-google" "eslint-config-prettier" "eslint-plugin-promise" "eslint-plugin-react-pug" "flow-bin" "html-webpack-plugin" "prettier" "webpack" "webpack-dev-server" "mocha" "chai")

DEPENDENCIES=()

YARN_FAILURES=()

yarn_add () {
  printf "Yarn add-ing $1..."
  yarn add $1 $2 --ignore-scripts &> /dev/null

  recent_code=$?
  if [[ $recent_code != 0 ]]; then
    printf "${RED}\n!! Yarn failed installing $1, be sure it installs properly manually\n${NORMAL}"
    YARN_FAILURES+=($1)
  else
    printf "${GREEN}done!${NORMAL}\n"
  fi
}

printf "Adding Development Dependency Node Packages via Yarn\n"
for package in ${DEV_DEPENDENCIES[@]}; do
  yarn_add $package "-D"
done
printf "\n\n"

printf "Adding Client Dependency Node Packages via Yarn\n"
for package in ${DEPENDENCIES[@]}; do
  yarn_add $package ""
done
printf "\n\n"

if [[ ${YARN_FAILURES[@]} > 0 ]]; then
  printf "${RED}The following packages failed to install.."
  for failure in ${YARN_FAILURES[@]}; do
    printf "$failure\n"
  done
  printf "\nPlease try installing them via the Yarn cli\n\n${NORMAL}"
fi
