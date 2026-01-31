import {
  AbsoluteFill,
  spring,
  useCurrentFrame,
  useVideoConfig,
} from "remotion";

export const SpringScale: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  // Logo bounces in
  const logoScale = spring({
    fps,
    frame,
    config: {
      damping: 10,
      stiffness: 100,
      mass: 0.5,
    },
  });

  // Text appears after logo (offset by 20 frames)
  const textScale = spring({
    fps,
    frame: frame - 20,
    config: {
      damping: 15,
      stiffness: 120,
    },
  });

  return (
    <AbsoluteFill
      style={{
        justifyContent: "center",
        alignItems: "center",
        backgroundColor: "#0f0f23",
        flexDirection: "column",
        gap: 40,
      }}
    >
      <div
        style={{
          width: 150,
          height: 150,
          borderRadius: 30,
          backgroundColor: "#FF6B6B",
          transform: `scale(${logoScale})`,
        }}
      />
      <h1
        style={{
          fontSize: 60,
          color: "white",
          transform: `scale(${Math.max(0, textScale)})`,
        }}
      >
        Spring Animation
      </h1>
    </AbsoluteFill>
  );
};
