import { AbsoluteFill, interpolate, useCurrentFrame } from "remotion";

export const FadeIn: React.FC<{ text: string }> = ({ text }) => {
  const frame = useCurrentFrame();

  // Fade in over 30 frames (1 second at 30fps)
  const opacity = interpolate(frame, [0, 30], [0, 1], {
    extrapolateRight: "clamp",
  });

  // Slide up 50px over same duration
  const translateY = interpolate(frame, [0, 30], [50, 0], {
    extrapolateRight: "clamp",
  });

  return (
    <AbsoluteFill
      style={{
        justifyContent: "center",
        alignItems: "center",
        backgroundColor: "#1a1a2e",
      }}
    >
      <h1
        style={{
          fontSize: 80,
          fontWeight: "bold",
          color: "white",
          opacity,
          transform: `translateY(${translateY}px)`,
        }}
      >
        {text}
      </h1>
    </AbsoluteFill>
  );
};
