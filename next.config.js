/** @type {import('next').NextConfig} */
// eslint-disable-next-line
const { withAxiom } = require("next-axiom");

const nextConfig = withAxiom({
  reactStrictMode: true,

  webpack: (config) => {
    config.module.rules.push({
      test: /\.svg$/,
      use: {
        loader: "@svgr/webpack",
        options: {
          titleProp: true,
          titleId: "filePath",
          svgoConfig: {
            plugins: [{ name: "removeViewBox", active: false }],
          },
        },
      },
    });

    config.module.rules.push({
      test: /\.(glsl|vs|fs|vert|frag)$/,
      exclude: /node_modules/,
      use: ["raw-loader", "glslify-loader"],
    });

    return config;
  },
});

module.exports = nextConfig;
