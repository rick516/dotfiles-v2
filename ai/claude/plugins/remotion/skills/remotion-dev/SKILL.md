---
name: Remotion Development
description: This skill should be used when the user asks to "create a video", "build a Remotion project", "animate with React", "render video", "use useCurrentFrame", "interpolate animation", "spring animation", "add Composition", "create Sequence", or mentions Remotion, programmatic video, or React video creation. Provides guidance for building videos programmatically with Remotion and React.
version: 1.0.0
---

# Remotion Development Guide

Remotion is a framework for creating videos programmatically using React. Videos are functions of images over time - each frame renders a React component with different props based on the current frame number.

## Core Concepts

### Frame-Based Animation

The fundamental principle: use `useCurrentFrame()` to get the current frame number and calculate visual properties from it. Never use CSS transitions or animations - they cause rendering issues.

```tsx
import { useCurrentFrame, useVideoConfig } from "remotion";

export const MyVideo: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps, durationInFrames, width, height } = useVideoConfig();

  // Calculate properties based on frame
  const opacity = Math.min(1, frame / 30);

  return <div style={{ opacity }}>Hello World</div>;
};
```

### Composition

A Composition combines a React component with video metadata. Register in `src/Root.tsx`:

```tsx
import { Composition } from "remotion";
import { MyVideo } from "./MyVideo";

export const RemotionRoot: React.FC = () => {
  return (
    <>
      <Composition
        id="MyVideo"
        component={MyVideo}
        durationInFrames={150}
        fps={30}
        width={1920}
        height={1080}
      />
    </>
  );
};
```

### AbsoluteFill

A layout component filling the entire canvas. Use for positioning with flexbox:

```tsx
import { AbsoluteFill } from "remotion";

export const MyVideo: React.FC = () => {
  return (
    <AbsoluteFill style={{ justifyContent: "center", alignItems: "center" }}>
      <h1>Centered Content</h1>
    </AbsoluteFill>
  );
};
```

## Animation Techniques

### interpolate()

Map input ranges to output ranges for readable animations:

```tsx
import { interpolate, useCurrentFrame } from "remotion";

const frame = useCurrentFrame();

// Fade in over frames 0-30
const opacity = interpolate(frame, [0, 30], [0, 1], {
  extrapolateRight: "clamp", // Prevent values > 1
});

// Scale from 0.5 to 1 over frames 0-60
const scale = interpolate(frame, [0, 60], [0.5, 1], {
  extrapolateLeft: "clamp",
  extrapolateRight: "clamp",
});
```

### spring()

Create natural, physics-based animations with overshoot:

```tsx
import { spring, useCurrentFrame, useVideoConfig } from "remotion";

const frame = useCurrentFrame();
const { fps } = useVideoConfig();

// Spring animates from 0 to 1
const scale = spring({
  fps,
  frame,
  config: {
    damping: 10,
    stiffness: 100,
    mass: 1,
  },
});
```

### Combining Animations

```tsx
const frame = useCurrentFrame();
const { fps } = useVideoConfig();

// Stagger animations using frame offset
const titleSpring = spring({ fps, frame: frame - 0, config: { damping: 15 } });
const subtitleSpring = spring({ fps, frame: frame - 15, config: { damping: 15 } });

return (
  <AbsoluteFill>
    <h1 style={{ transform: `scale(${titleSpring})` }}>Title</h1>
    <h2 style={{ transform: `scale(${subtitleSpring})` }}>Subtitle</h2>
  </AbsoluteFill>
);
```

## Sequences

Use `<Sequence>` to offset content in time:

```tsx
import { Sequence, AbsoluteFill } from "remotion";

export const MyVideo: React.FC = () => {
  return (
    <AbsoluteFill>
      <Sequence from={0} durationInFrames={60}>
        <Title text="First" />
      </Sequence>
      <Sequence from={60} durationInFrames={60}>
        <Title text="Second" />
      </Sequence>
    </AbsoluteFill>
  );
};
```

Inside a Sequence, `useCurrentFrame()` returns 0 at the start of that sequence.

## Series

Use `<Series>` for sequential content without manual frame calculation:

```tsx
import { Series } from "remotion";

export const MyVideo: React.FC = () => {
  return (
    <Series>
      <Series.Sequence durationInFrames={60}>
        <Intro />
      </Series.Sequence>
      <Series.Sequence durationInFrames={120}>
        <MainContent />
      </Series.Sequence>
      <Series.Sequence durationInFrames={30}>
        <Outro />
      </Series.Sequence>
    </Series>
  );
};
```

## Media Assets

### Images

```tsx
import { Img, staticFile } from "remotion";

// From public folder
<Img src={staticFile("logo.png")} />

// From URL
<Img src="https://example.com/image.png" />
```

### Video

```tsx
import { Video, staticFile } from "remotion";

<Video src={staticFile("background.mp4")} />
```

### Audio

```tsx
import { Audio, staticFile, useCurrentFrame } from "remotion";

// Basic audio
<Audio src={staticFile("music.mp3")} />

// With volume control
const frame = useCurrentFrame();
const volume = interpolate(frame, [0, 30], [0, 1], { extrapolateRight: "clamp" });

<Audio src={staticFile("music.mp3")} volume={volume} />
```

## Rendering

### Preview

```bash
npx remotion studio
```

### Render to File

```bash
# MP4
npx remotion render src/index.ts MyVideo out/video.mp4

# GIF
npx remotion render src/index.ts MyVideo out/video.gif --codec=gif

# With quality settings
npx remotion render src/index.ts MyVideo out/video.mp4 --crf=18
```

### Programmatic Rendering

```tsx
import { bundle } from "@remotion/bundler";
import { renderMedia, selectComposition } from "@remotion/renderer";

const bundled = await bundle({ entryPoint: "./src/index.ts" });
const composition = await selectComposition({ serveUrl: bundled, id: "MyVideo" });

await renderMedia({
  composition,
  serveUrl: bundled,
  codec: "h264",
  outputLocation: "out/video.mp4",
});
```

## Project Setup

### Create New Project

```bash
npx create-video@latest
```

### Project Structure

```
my-video/
├── src/
│   ├── index.ts        # Entry point
│   ├── Root.tsx        # Composition registry
│   └── MyVideo.tsx     # Video components
├── public/             # Static assets
├── remotion.config.ts  # Remotion config
└── package.json
```

## Best Practices

### Animation Performance

- Always derive animations from `useCurrentFrame()`, never CSS transitions
- Use `spring()` for natural motion with overshoot
- Use `interpolate()` with `extrapolateRight: "clamp"` to prevent overflow
- Offset frames for staggered animations: `spring({ frame: frame - 30 })`

### Code Organization

- One component per scene/section
- Use `<Sequence>` or `<Series>` to compose timeline
- Keep Compositions in `Root.tsx`
- Extract reusable animations as custom hooks

### Asset Handling

- Place static files in `public/` folder
- Use `staticFile()` helper for proper paths
- Preload large assets with `delayRender()` / `continueRender()`

## MCP Integration

This plugin includes the Remotion Documentation MCP server, which provides access to the full Remotion documentation. When working with Remotion, consult the MCP tools for detailed API references and examples.

## Additional Resources

### Reference Files

- **`references/api-reference.md`** - Complete API documentation
- **`references/rendering-options.md`** - All rendering configurations

### Examples

- **`examples/fade-in.tsx`** - Basic fade-in animation
- **`examples/spring-scale.tsx`** - Spring animation example
- **`examples/sequence-timeline.tsx`** - Multi-scene video structure
