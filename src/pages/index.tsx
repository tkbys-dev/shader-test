import { Stage, Graphics, useTick } from "@pixi/react";
import * as PIXI from "pixi.js";
import { defaultFilterVertex } from "@pixi/core";
import {
  useWindowSize,
  useWindowWidth,
  useWindowHeight,
} from "@react-hook/window-size";
import Vertex1 from "@/shaders/vertex/vertex1.glsl";
import Fragment2 from "@/shaders/fragment/fragment2.glsl";
import Fragment3 from "@/shaders/fragment/fragment3.glsl";
import Fragment4 from "@/shaders/fragment/fragment4.glsl";
import Fragment5 from "@/shaders/fragment/fragment5.glsl";
import Fragment6 from "@/shaders/fragment/fragment6.glsl";
import Fragment7 from "@/shaders/fragment/fragment7.glsl";
import Fragment8 from "@/shaders/fragment/fragment8.glsl";
import Fragment9 from "@/shaders/fragment/fragment9.glsl";

interface ISize {
  width: number;
  height: number;
}

const Sample = ({ width, height }: ISize) => {
  const shader2 = [
    new PIXI.Filter(defaultFilterVertex, Fragment2, {
      uResolution: [width * 2, height * 2],
      uTime: 0.1,
    }),
  ];

  const shader3 = [
    new PIXI.Filter(defaultFilterVertex, Fragment3, {
      uResolution: [width * 2, height * 2],
      uTime: 0.1,
      uFrame: 1,
      uMouse: [1, 1, 1],
    }),
  ];

  const shader4 = [
    new PIXI.Filter(defaultFilterVertex, Fragment4, {
      uResolution: [50, 50],
      uTime: 0.1,
      mainTex: PIXI.Texture.from("/test4.jpg"),
    }),
  ];

  const shader5 = [
    new PIXI.Filter(defaultFilterVertex, Fragment5, {
      uResolution: [width, height],
      uTime: 0.1,
    }),
  ];

  const shader6 = [
    new PIXI.Filter(defaultFilterVertex, Fragment6, {
      uResolution: [width * 1.1, height * 1.1],
      uTime: 0.1,
    }),
  ];

  const shader7 = [
    new PIXI.Filter(defaultFilterVertex, Fragment7, {
      uResolution: [100, 100],
      uTime: 0.1,
    }),
  ];

  const shader8 = [
    new PIXI.Filter(defaultFilterVertex, Fragment8, {
      uResolution: [width * 1.2, height * 1.2],
      uTime: 0.8,
    }),
  ];

  const shader9 = [
    new PIXI.Filter(defaultFilterVertex, Fragment9, {
      uResolution: [width, height],
      uTime: 0.8,
    }),
  ];

  useTick((time) => {
    shader2[0].uniforms.uTime += time * 0.01;
    shader4[0].uniforms.uTime += time * 0.00001;
    shader5[0].uniforms.uTime += time * 0.01;
    shader6[0].uniforms.uTime += time * 0.01;
    shader7[0].uniforms.uTime += time * 0.01;
    shader8[0].uniforms.uTime += time * 0.01;
    shader9[0].uniforms.uTime += time * 0.01;
  });

  return (
    <Graphics
      draw={(graphics) => {
        graphics.clear();
        graphics.beginFill(0x000000);
        graphics.drawRect(0, 0, width, height);
        graphics.endFill();
      }}
      filters={shader9}
    />
  );
};

export default function Home() {
  const w = useWindowWidth();
  const h = useWindowHeight();
  return (
    <Stage width={w} height={h}>
      <Sample width={w} height={h} />
    </Stage>
  );
}
