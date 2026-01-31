import {
  AbsoluteFill,
  Sequence,
  spring,
  useCurrentFrame,
  useVideoConfig,
} from "remotion";

// Reusable scene component
const Scene: React.FC<{
  title: string;
  backgroundColor: string;
}> = ({ title, backgroundColor }) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const scale = spring({
    fps,
    frame,
    config: { damping: 12 },
  });

  return (
    <AbsoluteFill
      style={{
        justifyContent: "center",
        alignItems: "center",
        backgroundColor,
      }}
    >
      <h1
        style={{
          fontSize: 80,
          color: "white",
          transform: `scale(${scale})`,
        }}
      >
        {title}
      </h1>
    </AbsoluteFill>
  );
};

// Main video with multiple scenes
export const SequenceTimeline: React.FC = () => {
  // 30fps * 2 seconds = 60 frames per scene
  const SCENE_DURATION = 60;

  return (
    <AbsoluteFill>
      {/* Scene 1: frames 0-59 */}
      <Sequence from={0} durationInFrames={SCENE_DURATION}>
        <Scene title="Introduction" backgroundColor="#1a1a2e" />
      </Sequence>

      {/* Scene 2: frames 60-119 */}
      <Sequence from={SCENE_DURATION} durationInFrames={SCENE_DURATION}>
        <Scene title="Main Content" backgroundColor="#16213e" />
      </Sequence>

      {/* Scene 3: frames 120-179 */}
      <Sequence from={SCENE_DURATION * 2} durationInFrames={SCENE_DURATION}>
        <Scene title="Conclusion" backgroundColor="#0f3460" />
      </Sequence>

      {/* Persistent overlay (appears throughout) */}
      <Sequence from={0}>
        <AbsoluteFill
          style={{
            justifyContent: "flex-end",
            alignItems: "center",
            paddingBottom: 30,
          }}
        >
          <p style={{ color: "rgba(255,255,255,0.5)", fontSize: 16 }}>
            Made with Remotion
          </p>
        </AbsoluteFill>
      </Sequence>
    </AbsoluteFill>
  );
};
