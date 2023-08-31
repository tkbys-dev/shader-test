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
    }),
  ];

  useTick((time) => {
    shader2[0].uniforms.uTime += time * 0.01;
  });

  return (
    <Graphics
      draw={(graphics) => {
        graphics.clear();
        graphics.beginFill(0x000000);
        graphics.drawRect(0, 0, width, height);
        graphics.endFill();
      }}
      filters={shader2}
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
