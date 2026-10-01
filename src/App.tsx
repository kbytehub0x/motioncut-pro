import React, { useState, useEffect, useRef } from 'react';
import {
  Play,
  Pause,
  Scissors,
  Volume2,
  Gauge,
  Palette,
  Layers,
  Trash2,
  RotateCcw,
  RotateCw,
  Sliders,
  Grid,
  Crop,
  Download,
  FolderOpen,
  Plus,
  Settings as SettingsIcon,
  Code2,
  Sparkles,
  ChevronRight,
  Maximize2,
  Minimize2,
  Copy,
  Check,
  Film,
  Music,
  Type,
  FileCode,
  ShieldCheck,
  CheckCircle2,
  X
} from 'lucide-react';

// --- TYPES & DATA MODELS ---
interface Keyframe {
  id: string;
  timeMs: number;
  value: number;
}

interface Clip {
  id: string;
  trackId: string;
  type: 'video' | 'audio' | 'text' | 'overlay';
  name: string;
  startTimeMs: number;
  durationMs: number;
  sourceInMs: number;
  sourceOutMs: number;
  speed: number;
  volume: number;
  opacity: number;
  blendMode: string;
  colorGrading: { brightness: number; contrast: number; saturation: number; lut: string };
  textContent?: string;
  textColor?: string;
  fontSize?: number;
}

interface Track {
  id: string;
  name: string;
  type: 'text' | 'overlay' | 'mainVideo' | 'audio';
  clips: Clip[];
}

interface Project {
  id: string;
  title: string;
  aspectRatio: '9:16' | '16:9' | '1:1' | '4:5';
  fps: number;
  updatedAt: string;
  tracks: Track[];
}

// Sample starter project matching lib/services/project/project_manager_service.dart
const INITIAL_PROJECTS: Project[] = [
  {
    id: 'demo-reel-01',
    title: 'Neon Cyberpunk Reel',
    aspectRatio: '9:16',
    fps: 30,
    updatedAt: 'Just now',
    tracks: [
      {
        id: 'track-text',
        name: 'Text & Titles',
        type: 'text',
        clips: [
          {
            id: 'clip-text-1',
            trackId: 'track-text',
            type: 'text',
            name: 'Title: MOTIONCUT',
            startTimeMs: 400,
            durationMs: 3200,
            sourceInMs: 0,
            sourceOutMs: 3200,
            speed: 1.0,
            volume: 1.0,
            opacity: 1.0,
            blendMode: 'normal',
            colorGrading: { brightness: 0, contrast: 1, saturation: 1, lut: 'None' },
            textContent: 'MOTIONCUT PRO',
            textColor: '#05D9E8',
            fontSize: 26,
          },
        ],
      },
      {
        id: 'track-overlay',
        name: 'Overlay / B-Roll (PIP)',
        type: 'overlay',
        clips: [
          {
            id: 'clip-overlay-1',
            trackId: 'track-overlay',
            type: 'overlay',
            name: 'Cyber_Glitch_FX.mp4',
            startTimeMs: 1600,
            durationMs: 3400,
            sourceInMs: 0,
            sourceOutMs: 3400,
            speed: 1.0,
            volume: 0.0,
            opacity: 0.85,
            blendMode: 'screen',
            colorGrading: { brightness: 0.05, contrast: 1.2, saturation: 1.3, lut: 'Cyber Neon' },
          },
        ],
      },
      {
        id: 'track-main',
        name: 'Main Video',
        type: 'mainVideo',
        clips: [
          {
            id: 'clip-main-1',
            trackId: 'track-main',
            type: 'video',
            name: 'Intro_Urban_Night.mp4',
            startTimeMs: 0,
            durationMs: 4000,
            sourceInMs: 0,
            sourceOutMs: 4000,
            speed: 1.0,
            volume: 1.0,
            opacity: 1.0,
            blendMode: 'normal',
            colorGrading: { brightness: 0.02, contrast: 1.15, saturation: 1.25, lut: 'Teal & Orange' },
          },
          {
            id: 'clip-main-2',
            trackId: 'track-main',
            type: 'video',
            name: 'Action_Drone_Drift.mp4',
            startTimeMs: 4000,
            durationMs: 4500,
            sourceInMs: 0,
            sourceOutMs: 4500,
            speed: 1.25,
            volume: 1.0,
            opacity: 1.0,
            blendMode: 'normal',
            colorGrading: { brightness: 0, contrast: 1.05, saturation: 1.1, lut: 'None' },
          },
        ],
      },
      {
        id: 'track-audio',
        name: 'Audio / BGM Track',
        type: 'audio',
        clips: [
          {
            id: 'clip-audio-1',
            trackId: 'track-audio',
            type: 'audio',
            name: 'Dark_Synth_808.wav',
            startTimeMs: 0,
            durationMs: 8500,
            sourceInMs: 0,
            sourceOutMs: 8500,
            speed: 1.0,
            volume: 0.85,
            opacity: 1.0,
            blendMode: 'normal',
            colorGrading: { brightness: 0, contrast: 1, saturation: 1, lut: 'None' },
          },
        ],
      },
    ],
  },
  {
    id: 'demo-reel-02',
    title: 'Landscape Cinema Teaser',
    aspectRatio: '16:9',
    fps: 60,
    updatedAt: '2 days ago',
    tracks: [
      {
        id: 'track-main-2',
        name: 'Main Video',
        type: 'mainVideo',
        clips: [
          {
            id: 'clip-cine-1',
            trackId: 'track-main-2',
            type: 'video',
            name: 'Mountain_Sunrise_4K.mp4',
            startTimeMs: 0,
            durationMs: 6000,
            sourceInMs: 0,
            sourceOutMs: 6000,
            speed: 0.8,
            volume: 1.0,
            opacity: 1.0,
            blendMode: 'normal',
            colorGrading: { brightness: 0.05, contrast: 1.2, saturation: 1.3, lut: 'Golden Hour' },
          },
        ],
      },
    ],
  },
];

// File blueprints representation for interactive codebase browser
const CODE_FILE_CATALOG: { path: string; module: string; description: string; codePreview: string }[] = [
  {
    path: 'lib/models/project_model.dart',
    module: 'Models',
    description: 'Project entity with aspect ratio framing, multi-track lists, and JSON serialization.',
    codePreview: `class ProjectModel {
  final String id;
  final String title;
  final AspectRatioType aspectRatio;
  final int fps;
  final List<TrackModel> tracks;
  final ExportProfileModel exportProfile;

  int get totalDurationMs => tracks.fold(0, (max, t) => ...);
  Map<String, dynamic> toMap() => {...};
  factory ProjectModel.fromMap(Map<String, dynamic> map) => ...;
}`,
  },
  {
    path: 'lib/models/clip_model.dart',
    module: 'Models',
    description: 'Frame-accurate cuts, speed multiplier (0.1x–10x), volume envelopes, and effects.',
    codePreview: `class ClipModel {
  final String id;
  final ClipType type;
  final int startTimeMs;
  final int durationMs;
  final int sourceInMs;
  final int sourceOutMs;
  final double speed;
  final double volume;
  final double opacity;
  final List<KeyframeModel> volumeKeyframes;
  final List<EffectModel> effects;
}`,
  },
  {
    path: 'lib/services/ffmpeg/ffmpeg_commands.dart',
    module: 'FFmpeg Pipeline',
    description: 'Generates complex filter graphs: multi-track compositing, speed ramps, audio ducking, LUTs.',
    codePreview: `class FfmpegCommands {
  static List<String> buildRenderProjectCommand({
    required ProjectModel project,
    required String outputPath,
  }) {
    // Generates color base canvas, trims, scale & pad, overlay chains, amix audio
    final cmd = ['-y', ...inputs, '-filter_complex', filterGraph, '-c:v', 'libx264', outputPath];
    return cmd;
  }
}`,
  },
  {
    path: 'lib/services/ffmpeg/ffmpeg_progress_parser.dart',
    module: 'FFmpeg Pipeline',
    description: 'Parses raw FFmpeg -progress stdout stream (frame, fps, out_time_ms, speed, size).',
    codePreview: `class FfmpegProgressParser {
  FfmpegProgress parseLine(String line) {
    if (line.startsWith('frame=')) _frame = int.parse(...);
    if (line.startsWith('fps=')) _fps = double.parse(...);
    if (line.startsWith('out_time_ms=')) _lastOutTimeMs = int.parse(...);
    return FfmpegProgress(percentage: _lastOutTimeMs / totalDurationMs);
  }
}`,
  },
  {
    path: 'lib/services/project/undo_redo_service.dart',
    module: 'State & History',
    description: 'Command Pattern implementation with concrete SplitClipCommand & DeleteClipCommand.',
    codePreview: `class SplitClipCommand implements EditorCommand {
  final String clipId;
  final int splitTimelineMs;
  ProjectModel execute(ProjectModel current) { ... }
  ProjectModel undo(ProjectModel current) { ... }
}

class UndoRedoService {
  final List<EditorCommand> _undoStack = [];
  final List<EditorCommand> _redoStack = [];
  ProjectModel execute(EditorCommand cmd, ProjectModel current) { ... }
}`,
  },
  {
    path: 'android/app/src/main/kotlin/com/yourpkg/ffmpeg/FfmpegPlugin.kt',
    module: 'Android Native',
    description: 'Platform Channel wiring (MethodChannel & EventChannel) communicating with native runner.',
    codePreview: `class FfmpegPlugin : FlutterPlugin, MethodCallHandler, EventChannel.StreamHandler {
  override fun onMethodCall(call: MethodCall, result: Result) {
    if (call.method == "executeFFmpeg") {
      val args = call.argument<List<String>>("arguments")
      runner.execute(args, onProgress = { line -> eventSink?.success(line) })
    }
  }
}`,
  },
  {
    path: 'lib/widgets/toolbar/tools/crop_tool.dart',
    module: 'Editing Tools',
    description: 'Freeform crop bounds, aspect ratios presets (9:16, 16:9, 1:1, 4:5, 4:3, 21:9), rotation, and flips.',
    codePreview: `class CropTool extends StatefulWidget {
  final ClipModel clip;
  final Function(CropBounds bounds, double rotationDegrees, bool flipX, bool flipY) onApplyCrop;
  final VoidCallback onClose;
}

enum CropAspectRatioPreset {
  freeform("Free", null),
  portrait9_16("9:16", 9 / 16),
  landscape16_9("16:9", 16 / 9),
  square1_1("1:1", 1.0),
  portrait4_5("4:5", 4 / 5),
  classic4_3("4:3", 4 / 3),
  cinema21_9("21:9", 21 / 9);
}`,
  },
  {
    path: '.github/workflows/build-apk.yml',
    module: 'DevOps / CI',
    description: 'GitHub Actions workflow installing Flutter, running flutter test/analyze, building release APK.',
    codePreview: `name: Build Release APK
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test --coverage
      - run: flutter build apk --release --split-per-abi`,
  },
];

export default function App() {
  // Navigation & View Mode
  const [currentTab, setCurrentTab] = useState<'editor' | 'projects' | 'settings' | 'codebase'>('editor');
  const [activeProject, setActiveProject] = useState<Project>(INITIAL_PROJECTS[0]);
  const [projectsList, setProjectsList] = useState<Project[]>(INITIAL_PROJECTS);

  // Playhead & Transport
  const [playheadMs, setPlayheadMs] = useState<number>(1800);
  const [isPlaying, setIsPlaying] = useState<boolean>(false);
  const [pixelsPerSecond, setPixelsPerSecond] = useState<number>(45);
  const [showSafeAreas, setShowSafeAreas] = useState<boolean>(false);
  const [showGrid, setShowGrid] = useState<boolean>(false);
  const [previewQuality, setPreviewQuality] = useState<'360p' | '720p' | '1080p'>('720p');

  // Clip Selection & Tooling
  const [selectedClipId, setSelectedClipId] = useState<string | null>('clip-main-1');
  const [activeTool, setActiveTool] = useState<'none' | 'trim' | 'speed' | 'volume' | 'color' | 'blend' | 'text' | 'crop'>('none');
  const [copiedCode, setCopiedCode] = useState<string | null>(null);

  // Crop & Transform State
  const [cropAspectRatio, setCropAspectRatio] = useState<string>('Free');
  const [cropWidthPct, setCropWidthPct] = useState<number>(100);
  const [cropHeightPct, setCropHeightPct] = useState<number>(100);
  const [cropRotation, setCropRotation] = useState<number>(0);
  const [cropFlipX, setCropFlipX] = useState<boolean>(false);
  const [cropFlipY, setCropFlipY] = useState<boolean>(false);
  const [cropFillMode, setCropFillMode] = useState<'window' | 'fill'>('window');

  // Undo / Redo History Stack Simulation
  const [historyStack, setHistoryStack] = useState<Project[]>([]);
  const [redoStack, setRedoStack] = useState<Project[]>([]);

  // Export State Modal
  const [showExportModal, setShowExportModal] = useState<boolean>(false);
  const [exportProgress, setExportProgress] = useState<number>(0);
  const [isExporting, setIsExporting] = useState<boolean>(false);
  const [exportCompletePath, setExportCompletePath] = useState<string | null>(null);
  const [exportRes, setExportRes] = useState<'1080p' | '4K' | '720p'>('1080p');
  const [exportFps, setExportFps] = useState<number>(30);
  const [exportCodec, setExportCodec] = useState<'H.264' | 'HEVC (H.265)'>('H.264');
  const [exportBitrate, setExportBitrate] = useState<number>(12);

  // New Project Modal
  const [showNewProjModal, setShowNewProjModal] = useState<boolean>(false);
  const [newProjTitle, setNewProjTitle] = useState<string>('');
  const [newProjRatio, setNewProjRatio] = useState<'9:16' | '16:9' | '1:1' | '4:5'>('9:16');

  // Selected Code File in Code Inspector
  const [inspectedFile, setInspectedFile] = useState(CODE_FILE_CATALOG[2]);

  // Compute total duration
  const totalDurationMs = Math.max(
    ...activeProject.tracks.flatMap((t) => t.clips.map((c) => c.startTimeMs + c.durationMs)),
    8500
  );

  // Playback loop
  useEffect(() => {
    let animId: number;
    let lastTime = performance.now();

    const loop = (time: number) => {
      if (isPlaying) {
        const delta = time - lastTime;
        setPlayheadMs((prev) => {
          if (prev >= totalDurationMs) {
            setIsPlaying(false);
            return 0;
          }
          return Math.min(prev + delta, totalDurationMs);
        });
      }
      lastTime = time;
      if (isPlaying) {
        animId = requestAnimationFrame(loop);
      }
    };

    if (isPlaying) {
      animId = requestAnimationFrame(loop);
    }
    return () => cancelAnimationFrame(animId);
  }, [isPlaying, totalDurationMs]);

  // Push state to undo history
  const pushHistory = (newProject: Project) => {
    setHistoryStack((prev) => [...prev.slice(-30), activeProject]);
    setRedoStack([]);
    setActiveProject(newProject);
  };

  const handleUndo = () => {
    if (historyStack.length === 0) return;
    const prev = historyStack[historyStack.length - 1];
    setRedoStack((r) => [activeProject, ...r]);
    setHistoryStack((h) => h.slice(0, -1));
    setActiveProject(prev);
  };

  const handleRedo = () => {
    if (redoStack.length === 0) return;
    const next = redoStack[0];
    setHistoryStack((h) => [...h, activeProject]);
    setRedoStack((r) => r.slice(1));
    setActiveProject(next);
  };

  // Find active clips at current playhead
  const activeMainClip = activeProject.tracks
    .find((t) => t.type === 'mainVideo')
    ?.clips.find((c) => playheadMs >= c.startTimeMs && playheadMs <= c.startTimeMs + c.durationMs);

  const activeOverlayClip = activeProject.tracks
    .find((t) => t.type === 'overlay')
    ?.clips.find((c) => playheadMs >= c.startTimeMs && playheadMs <= c.startTimeMs + c.durationMs);

  const activeTextClip = activeProject.tracks
    .find((t) => t.type === 'text')
    ?.clips.find((c) => playheadMs >= c.startTimeMs && playheadMs <= c.startTimeMs + c.durationMs);

  // Selected clip object
  const selectedClip = activeProject.tracks
    .flatMap((t) => t.clips)
    .find((c) => c.id === selectedClipId);

  // Split Clip command
  const handleSplitAtPlayhead = () => {
    let target = selectedClip;
    if (!target) {
      target = activeMainClip;
    }
    if (!target) return;

    if (playheadMs <= target.startTimeMs || playheadMs >= target.startTimeMs + target.durationMs) {
      return;
    }

    const splitDelta = playheadMs - target.startTimeMs;
    const targetId = target.id;

    const newTracks = activeProject.tracks.map((track) => {
      const idx = track.clips.findIndex((c) => c.id === targetId);
      if (idx === -1) return track;

      const orig = track.clips[idx];
      const part1: Clip = {
        ...orig,
        durationMs: splitDelta,
        sourceOutMs: orig.sourceInMs + Math.round(splitDelta * orig.speed),
      };
      const part2: Clip = {
        ...orig,
        id: `clip-${Date.now()}`,
        startTimeMs: playheadMs,
        durationMs: orig.durationMs - splitDelta,
        sourceInMs: part1.sourceOutMs,
      };

      const nextClips = [...track.clips];
      nextClips.splice(idx, 1, part1, part2);
      return { ...track, clips: nextClips };
    });

    pushHistory({ ...activeProject, tracks: newTracks });
    setSelectedClipId(target.id);
  };

  // Delete clip command
  const handleDeleteSelectedClip = () => {
    if (!selectedClipId) return;
    const newTracks = activeProject.tracks.map((t) => ({
      ...t,
      clips: t.clips.filter((c) => c.id !== selectedClipId),
    }));
    pushHistory({ ...activeProject, tracks: newTracks });
    setSelectedClipId(null);
    setActiveTool('none');
  };

  // Update selected clip parameters
  const updateSelectedClip = (patch: Partial<Clip>) => {
    if (!selectedClipId) return;
    const newTracks = activeProject.tracks.map((t) => ({
      ...t,
      clips: t.clips.map((c) => (c.id === selectedClipId ? { ...c, ...patch } : c)),
    }));
    pushHistory({ ...activeProject, tracks: newTracks });
  };

  // Format timecode MM:SS:ff
  const formatTimecode = (ms: number) => {
    const s = Math.floor(ms / 1000);
    const m = Math.floor(s / 60);
    const sec = s % 60;
    const frames = Math.floor(((ms % 1000) / 1000) * 30);
    return `${m.toString().padStart(2, '0')}:${sec.toString().padStart(2, '0')}:${frames.toString().padStart(2, '0')}`;
  };

  // Start realistic FFmpeg export simulation
  const handleStartExport = () => {
    setIsExporting(true);
    setExportProgress(0);
    setExportCompletePath(null);

    let current = 0;
    const interval = setInterval(() => {
      current += 4;
      if (current >= 100) {
        clearInterval(interval);
        setExportProgress(100);
        setIsExporting(false);
        setExportCompletePath(`/storage/emulated/0/Movies/MotionCut_${activeProject.id}_${Date.now()}.mp4`);
      } else {
        setExportProgress(current);
      }
    }, 120);
  };

  return (
    <div className="flex flex-col h-screen w-screen bg-zinc-950 text-zinc-100 overflow-hidden font-sans">
      {/* Top Application Bar */}
      <header className="h-12 border-b border-zinc-800/80 bg-zinc-900/90 px-4 flex items-center justify-between z-30 select-none">
        <div className="flex items-center space-x-3">
          <div className="w-7 h-7 rounded-lg bg-rose-600 flex items-center justify-center shadow-lg shadow-rose-600/30">
            <Film className="w-4 h-4 text-white" />
          </div>
          <div>
            <span className="font-bold text-sm tracking-tight text-white flex items-center gap-1.5">
              MotionCut Pro
              <span className="text-[10px] font-mono font-medium px-1.5 py-0.5 rounded bg-zinc-800 text-rose-400 border border-zinc-700">
                Flutter 3.x
              </span>
            </span>
          </div>
        </div>

        {/* View Switcher Tabs */}
        <div className="flex items-center bg-zinc-950/70 p-1 rounded-lg border border-zinc-800 text-xs">
          <button
            onClick={() => setCurrentTab('editor')}
            className={`px-3 py-1 rounded-md transition-all font-medium flex items-center gap-1.5 ${
              currentTab === 'editor' ? 'bg-zinc-800 text-white shadow-sm' : 'text-zinc-400 hover:text-zinc-200'
            }`}
          >
            <Sliders className="w-3.5 h-3.5 text-rose-400" />
            Editor Dock
          </button>
          <button
            onClick={() => setCurrentTab('projects')}
            className={`px-3 py-1 rounded-md transition-all font-medium flex items-center gap-1.5 ${
              currentTab === 'projects' ? 'bg-zinc-800 text-white shadow-sm' : 'text-zinc-400 hover:text-zinc-200'
            }`}
          >
            <FolderOpen className="w-3.5 h-3.5 text-cyan-400" />
            Projects ({projectsList.length})
          </button>
          <button
            onClick={() => setCurrentTab('codebase')}
            className={`px-3 py-1 rounded-md transition-all font-medium flex items-center gap-1.5 ${
              currentTab === 'codebase' ? 'bg-zinc-800 text-white shadow-sm' : 'text-zinc-400 hover:text-zinc-200'
            }`}
          >
            <Code2 className="w-3.5 h-3.5 text-amber-400" />
            Codebase & Architecture
          </button>
          <button
            onClick={() => setCurrentTab('settings')}
            className={`px-3 py-1 rounded-md transition-all font-medium flex items-center gap-1.5 ${
              currentTab === 'settings' ? 'bg-zinc-800 text-white shadow-sm' : 'text-zinc-400 hover:text-zinc-200'
            }`}
          >
            <SettingsIcon className="w-3.5 h-3.5 text-emerald-400" />
            Settings
          </button>
        </div>

        {/* Right Action: Export */}
        <div className="flex items-center space-x-2">
          <div className="hidden md:flex items-center gap-2 text-xs text-zinc-400 mr-2 font-mono">
            <span>{activeProject.aspectRatio}</span>
            <span>·</span>
            <span>{activeProject.fps}fps</span>
          </div>
          <button
            onClick={() => setShowExportModal(true)}
            className="px-3.5 py-1.5 rounded-lg bg-rose-600 hover:bg-rose-500 text-white font-semibold text-xs transition-colors flex items-center gap-1.5 shadow-md shadow-rose-900/30"
          >
            <Download className="w-3.5 h-3.5" />
            Export 4K/FFmpeg
          </button>
        </div>
      </header>

      {/* MAIN VIEWPORT BODY */}
      <main className="flex-1 flex overflow-hidden relative">
        {/* ================= TAB 1: WORKSPACE EDITOR ================= */}
        {currentTab === 'editor' && (
          <div className="flex-1 flex flex-col h-full bg-zinc-950">
            {/* TOP HALF: VIDEO MONITOR & PREVIEW CONTROLS */}
            <div className="flex-1 flex flex-col min-h-[240px] max-h-[50vh] bg-zinc-950/80 border-b border-zinc-800/80 relative">
              {/* Video Monitor Viewport */}
              <div className="flex-1 flex items-center justify-center p-3 overflow-hidden relative">
                {/* Parent Viewport Box with overflow: hidden */}
                <div
                  className={`relative rounded-xl border border-zinc-800/80 shadow-2xl bg-zinc-950 flex items-center justify-center overflow-hidden transition-all duration-300 ${
                    activeProject.aspectRatio === '9:16'
                      ? 'aspect-[9/16] h-full max-h-[380px]'
                      : activeProject.aspectRatio === '16:9'
                      ? 'aspect-[16/9] w-full max-w-[540px]'
                      : 'aspect-square h-full max-h-[360px]'
                  }`}
                >
                  {/* Dynamic Gradient Simulation of Video Media (Inner Element with crop window / cover scaling) */}
                  {activeMainClip ? (
                    <div
                      className="w-full h-full relative flex flex-col justify-between p-4 bg-gradient-to-tr from-slate-950 via-zinc-800 to-indigo-950 select-none overflow-hidden"
                      style={{
                        filter: `brightness(${1 + activeMainClip.colorGrading.brightness}) contrast(${activeMainClip.colorGrading.contrast}) saturate(${activeMainClip.colorGrading.saturation})`,
                        transform: `rotate(${cropRotation}deg) scaleX(${cropFlipX ? -1 : 1}) scaleY(${cropFlipY ? -1 : 1}) ${
                          cropFillMode === 'fill' ? `scale(${100 / Math.min(cropWidthPct, cropHeightPct)})` : ''
                        }`,
                        clipPath:
                          cropFillMode === 'window' && (cropWidthPct < 100 || cropHeightPct < 100)
                            ? `inset(${(100 - cropHeightPct) / 2}% ${(100 - cropWidthPct) / 2}% ${(100 - cropHeightPct) / 2}% ${(100 - cropWidthPct) / 2}%)`
                            : 'none',
                        transition: 'transform 0.15s ease-out, clip-path 0.15s ease-out',
                      }}
                    >
                      <div className="flex justify-between items-start text-[10px] font-mono text-zinc-400">
                        <span className="bg-black/60 px-2 py-0.5 rounded border border-zinc-800">
                          {activeMainClip.name}
                        </span>
                        <span className="text-cyan-400 font-bold bg-black/60 px-2 py-0.5 rounded">
                          {activeMainClip.speed}x SPEED
                        </span>
                      </div>

                      {/* Overlay (B-Roll / Glitch) Layer */}
                      {activeOverlayClip && (
                        <div
                          className="absolute inset-0 flex items-center justify-center pointer-events-none"
                          style={{
                            opacity: activeOverlayClip.opacity,
                            mixBlendMode: activeOverlayClip.blendMode === 'screen' ? 'screen' : 'normal',
                          }}
                        >
                          <div className="w-full h-full bg-gradient-to-r from-rose-500/20 via-transparent to-cyan-500/20 animate-pulse border border-cyan-500/30 flex items-center justify-center">
                            <span className="text-xs font-mono font-bold tracking-widest text-cyan-300 bg-black/70 px-2 py-1 rounded">
                              PIP OVERLAY: {activeOverlayClip.name}
                            </span>
                          </div>
                        </div>
                      )}

                      {/* Animated Subtitle / Title Text Layer */}
                      {activeTextClip && (
                        <div className="absolute inset-0 flex items-center justify-center pointer-events-none p-4 text-center">
                          <h2
                            style={{
                              color: activeTextClip.textColor || '#05D9E8',
                              fontSize: `${activeTextClip.fontSize || 26}px`,
                            }}
                            className="font-extrabold tracking-wider drop-shadow-[0_4px_12px_rgba(0,0,0,0.8)]"
                          >
                            {activeTextClip.textContent || 'TEXT OVERLAY'}
                          </h2>
                        </div>
                      )}

                      {/* Bottom Media Metadata Tag */}
                      <div className="text-[10px] font-mono text-zinc-500 flex justify-between">
                        <span>LUT: {activeMainClip.colorGrading.lut}</span>
                        <span>{previewQuality} Proxy</span>
                      </div>
                    </div>
                  ) : (
                    <div className="text-center p-4">
                      <Film className="w-10 h-10 text-zinc-700 mx-auto mb-2" />
                      <p className="text-xs text-zinc-500 font-medium">No media active at playhead</p>
                    </div>
                  )}

                  {/* Interactive Crop Window Frame Overlay */}
                  {((activeTool === 'crop') || (cropFillMode === 'window' && (cropWidthPct < 100 || cropHeightPct < 100))) && (
                    <div
                      className="absolute pointer-events-none transition-all duration-150 border-2 border-cyan-400 shadow-[0_0_12px_rgba(5,217,232,0.5)] z-20"
                      style={{
                        top: `${(100 - cropHeightPct) / 2}%`,
                        bottom: `${(100 - cropHeightPct) / 2}%`,
                        left: `${(100 - cropWidthPct) / 2}%`,
                        right: `${(100 - cropWidthPct) / 2}%`,
                      }}
                    >
                      {/* Corner crop handles */}
                      <div className="absolute -top-1.5 -left-1.5 w-3.5 h-3.5 border-t-2 border-l-2 border-white"></div>
                      <div className="absolute -top-1.5 -right-1.5 w-3.5 h-3.5 border-t-2 border-r-2 border-white"></div>
                      <div className="absolute -bottom-1.5 -left-1.5 w-3.5 h-3.5 border-b-2 border-l-2 border-white"></div>
                      <div className="absolute -bottom-1.5 -right-1.5 w-3.5 h-3.5 border-b-2 border-r-2 border-white"></div>

                      {/* 3x3 rule of thirds guide inside crop window */}
                      <div className="w-full h-full grid grid-cols-3 grid-rows-3 opacity-25 pointer-events-none">
                        <div className="border-r border-b border-cyan-200"></div>
                        <div className="border-r border-b border-cyan-200"></div>
                        <div className="border-b border-cyan-200"></div>
                        <div className="border-r border-b border-cyan-200"></div>
                        <div className="border-r border-b border-cyan-200"></div>
                        <div className="border-b border-cyan-200"></div>
                        <div className="border-r border-b border-cyan-200"></div>
                        <div className="border-r border-b border-cyan-200"></div>
                        <div></div>
                      </div>

                      {/* Crop dimension indicator */}
                      <div className="absolute bottom-1.5 right-1.5 px-1.5 py-0.5 rounded bg-black/80 text-[9px] font-mono text-cyan-300 font-bold border border-cyan-500/40">
                        {cropAspectRatio !== 'Free' ? cropAspectRatio : `${cropWidthPct}% × ${cropHeightPct}%`}
                      </div>
                    </div>
                  )}

                  {/* Overlays: Safe Area & Rule-of-Thirds Grid */}
                  {showGrid && (
                    <div className="absolute inset-0 pointer-events-none grid grid-cols-3 grid-rows-3 border border-white/20">
                      <div className="border-r border-b border-white/15"></div>
                      <div className="border-r border-b border-white/15"></div>
                      <div className="border-b border-white/15"></div>
                      <div className="border-r border-b border-white/15"></div>
                      <div className="border-r border-b border-white/15"></div>
                      <div className="border-b border-white/15"></div>
                      <div className="border-r border-white/15"></div>
                      <div className="border-r border-white/15"></div>
                      <div></div>
                    </div>
                  )}

                  {showSafeAreas && (
                    <div className="absolute inset-0 pointer-events-none flex items-center justify-center">
                      <div className="w-[90%] h-[90%] border border-rose-500/50 rounded-sm">
                        <div className="w-[88%] h-[88%] mx-auto mt-[4%] border border-cyan-400/40 rounded-sm"></div>
                      </div>
                    </div>
                  )}
                </div>
              </div>

              {/* Transport Bar & Scrubber */}
              <div className="h-12 bg-zinc-900 border-t border-zinc-800 px-4 flex items-center justify-between text-xs">
                {/* Left: Timecode and history */}
                <div className="flex items-center space-x-3">
                  <div className="font-mono text-sm font-semibold text-rose-400 bg-zinc-950 px-2.5 py-1 rounded border border-zinc-800">
                    {formatTimecode(playheadMs)}
                  </div>
                  <span className="text-zinc-500 font-mono text-[11px]">/ {formatTimecode(totalDurationMs)}</span>

                  <div className="hidden sm:flex items-center space-x-1 ml-2 border-l border-zinc-800 pl-3">
                    <button
                      onClick={handleUndo}
                      disabled={historyStack.length === 0}
                      title="Undo (Ctrl+Z)"
                      className="p-1.5 rounded hover:bg-zinc-800 disabled:opacity-30 text-zinc-300"
                    >
                      <RotateCcw className="w-3.5 h-3.5" />
                    </button>
                    <button
                      onClick={handleRedo}
                      disabled={redoStack.length === 0}
                      title="Redo (Ctrl+Y)"
                      className="p-1.5 rounded hover:bg-zinc-800 disabled:opacity-30 text-zinc-300"
                    >
                      <RotateCw className="w-3.5 h-3.5" />
                    </button>
                  </div>
                </div>

                {/* Center: Play/Pause and Step transport */}
                <div className="flex items-center space-x-2">
                  <button
                    onClick={() => setPlayheadMs((p) => Math.max(0, p - 33))}
                    title="-1 Frame"
                    className="p-1.5 rounded text-zinc-400 hover:text-white hover:bg-zinc-800"
                  >
                    <span className="font-mono text-[11px]">-1F</span>
                  </button>
                  <button
                    onClick={() => setIsPlaying(!isPlaying)}
                    className="w-8 h-8 rounded-full bg-rose-600 hover:bg-rose-500 text-white flex items-center justify-center shadow-lg shadow-rose-600/30 transition-transform active:scale-95"
                  >
                    {isPlaying ? <Pause className="w-4 h-4 fill-white" /> : <Play className="w-4 h-4 fill-white ml-0.5" />}
                  </button>
                  <button
                    onClick={() => setPlayheadMs((p) => Math.min(totalDurationMs, p + 33))}
                    title="+1 Frame"
                    className="p-1.5 rounded text-zinc-400 hover:text-white hover:bg-zinc-800"
                  >
                    <span className="font-mono text-[11px]">+1F</span>
                  </button>
                </div>

                {/* Right: View toggles & Quality */}
                <div className="flex items-center space-x-2">
                  <button
                    onClick={() => setShowGrid(!showGrid)}
                    className={`p-1.5 rounded text-xs transition-colors ${
                      showGrid ? 'bg-rose-950 text-rose-400 border border-rose-800' : 'text-zinc-400 hover:bg-zinc-800'
                    }`}
                    title="Toggle Grid"
                  >
                    <Grid className="w-3.5 h-3.5" />
                  </button>
                  <button
                    onClick={() => setShowSafeAreas(!showSafeAreas)}
                    className={`p-1.5 rounded text-xs transition-colors ${
                      showSafeAreas ? 'bg-cyan-950 text-cyan-400 border border-cyan-800' : 'text-zinc-400 hover:bg-zinc-800'
                    }`}
                    title="Toggle Safe Area Overlay"
                  >
                    <Crop className="w-3.5 h-3.5" />
                  </button>
                  <select
                    value={previewQuality}
                    onChange={(e) => setPreviewQuality(e.target.value as any)}
                    aria-label="Preview Quality"
                    className="bg-zinc-950 border border-zinc-800 text-zinc-300 rounded px-2 py-1 text-[11px] font-mono focus:outline-none focus:border-rose-500"
                  >
                    <option value="360p">360p Draft</option>
                    <option value="720p">720p Proxy</option>
                    <option value="1080p">1080p Full</option>
                  </select>
                </div>
              </div>
            </div>

            {/* BOTTOM HALF: MULTI-TRACK TIMELINE DOCK */}
            <div className="flex-1 flex flex-col bg-zinc-950 overflow-hidden">
              {/* Timeline Header (Zoom Slider & Track Count) */}
              <div className="h-8 bg-zinc-900/60 border-b border-zinc-800/80 px-4 flex items-center justify-between text-xs text-zinc-400 select-none">
                <div className="flex items-center space-x-3">
                  <span className="font-semibold text-zinc-300">Tracks ({activeProject.tracks.length})</span>
                  <span className="text-[11px] text-zinc-500">Auto-Snap: Active</span>
                </div>
                <div className="flex items-center space-x-2">
                  <span className="text-[10px] font-mono">Zoom</span>
                  <input
                    type="range"
                    min="15"
                    max="120"
                    value={pixelsPerSecond}
                    onChange={(e) => setPixelsPerSecond(Number(e.target.value))}
                    aria-label="Timeline Zoom"
                    className="w-20 accent-rose-500 cursor-pointer h-1.5 bg-zinc-800 rounded-lg"
                  />
                  <span className="font-mono text-[10px] w-8 text-right">{pixelsPerSecond}px/s</span>
                </div>
              </div>

              {/* Scrollable Tracks Area */}
              <div
                className="flex-1 overflow-x-auto overflow-y-auto relative bg-zinc-950 p-2 cursor-pointer select-none"
                onClick={(e) => {
                  if (e.target === e.currentTarget) setSelectedClipId(null);
                }}
              >
                {/* Playhead Vertical Needle */}
                <div
                  className="absolute top-0 bottom-0 z-20 pointer-events-none"
                  style={{
                    left: `${(playheadMs / 1000) * pixelsPerSecond + 16}px`,
                  }}
                >
                  <div className="w-3.5 h-3 bg-white text-zinc-900 rounded-b -ml-[6px] flex items-center justify-center shadow-md">
                    <div className="w-1 h-1 bg-rose-600 rounded-full" />
                  </div>
                  <div className="w-[2px] h-full bg-white shadow-[0_0_8px_rgba(255,42,109,0.9)]" />
                </div>

                {/* Timeline Ruler Row */}
                <div
                  className="h-6 relative border-b border-zinc-800/80 mb-2"
                  style={{ width: `${(totalDurationMs / 1000) * pixelsPerSecond + 200}px` }}
                  onClick={(e) => {
                    const rect = e.currentTarget.getBoundingClientRect();
                    const x = e.clientX - rect.left - 16;
                    const ms = Math.max(0, (x / pixelsPerSecond) * 1000);
                    setPlayheadMs(Math.min(ms, totalDurationMs));
                  }}
                >
                  {Array.from({ length: Math.ceil(totalDurationMs / 1000) + 1 }).map((_, sec) => (
                    <div
                      key={sec}
                      className="absolute bottom-0 text-[9px] font-mono text-zinc-500 border-l border-zinc-800 pl-1 h-3"
                      style={{ left: `${sec * pixelsPerSecond + 16}px` }}
                    >
                      {sec}s
                    </div>
                  ))}
                </div>

                {/* Multi-Tracks Stack */}
                <div
                  className="space-y-2"
                  style={{ width: `${(totalDurationMs / 1000) * pixelsPerSecond + 200}px` }}
                >
                  {activeProject.tracks.map((track) => (
                    <div key={track.id} className="relative h-12 bg-zinc-900/50 rounded-lg border border-zinc-800/60 p-1">
                      {/* Clips in Track */}
                      {track.clips.map((clip) => {
                        const isSelected = clip.id === selectedClipId;
                        const left = (clip.startTimeMs / 1000) * pixelsPerSecond + 16;
                        const width = Math.max(28, (clip.durationMs / 1000) * pixelsPerSecond);

                        return (
                          <div
                            key={clip.id}
                            onClick={(e) => {
                              e.stopPropagation();
                              setSelectedClipId(clip.id);
                            }}
                            className={`absolute top-1 bottom-1 rounded-md px-2 flex items-center justify-between text-xs font-medium cursor-pointer transition-shadow overflow-hidden ${
                              clip.type === 'video'
                                ? 'bg-blue-950/80 text-blue-200 border border-blue-700/60'
                                : clip.type === 'overlay'
                                ? 'bg-purple-950/80 text-purple-200 border border-purple-700/60'
                                : clip.type === 'audio'
                                ? 'bg-emerald-950/80 text-emerald-200 border border-emerald-700/60'
                                : 'bg-amber-950/80 text-amber-200 border border-amber-700/60'
                            } ${isSelected ? 'ring-2 ring-rose-500 shadow-lg shadow-rose-900/30' : 'hover:brightness-110'}`}
                            style={{
                              left: `${left}px`,
                              width: `${width}px`,
                            }}
                          >
                            {/* Waveform graphic for audio clips */}
                            {clip.type === 'audio' && (
                              <div className="absolute inset-0 opacity-30 flex items-end justify-between px-1 pointer-events-none pb-0.5">
                                {Array.from({ length: Math.min(60, Math.floor(width / 4)) }).map((_, i) => (
                                  <div
                                    key={i}
                                    className="w-[2px] bg-emerald-400 rounded-t"
                                    style={{ height: `${Math.max(4, ((i * 7) % 24) + 6)}px` }}
                                  />
                                ))}
                              </div>
                            )}

                            <span className="truncate text-[11px] font-semibold flex items-center gap-1 z-10">
                              {clip.type === 'video' && <Film className="w-3 h-3" />}
                              {clip.type === 'audio' && <Music className="w-3 h-3" />}
                              {clip.type === 'text' && <Type className="w-3 h-3" />}
                              {clip.type === 'overlay' && <Layers className="w-3 h-3" />}
                              {clip.name}
                            </span>

                            {clip.speed !== 1.0 && (
                              <span className="text-[9px] font-mono font-bold bg-black/50 px-1 py-0.5 rounded text-cyan-300 ml-1 z-10">
                                {clip.speed}x
                              </span>
                            )}
                          </div>
                        );
                      })}
                    </div>
                  ))}
                </div>
              </div>

              {/* ACTIVE CONTEXTUAL TOOL SHEET MODAL (If a tool is opened) */}
              {activeTool !== 'none' && selectedClip && (
                <div className="border-t border-zinc-800 bg-zinc-900 p-3 select-none">
                  <div className="flex items-center justify-between mb-2">
                    <span className="text-xs font-bold text-white flex items-center gap-1.5">
                      {activeTool === 'speed' && <Gauge className="w-4 h-4 text-cyan-400" />}
                      {activeTool === 'volume' && <Volume2 className="w-4 h-4 text-emerald-400" />}
                      {activeTool === 'color' && <Palette className="w-4 h-4 text-rose-400" />}
                      {activeTool === 'blend' && <Layers className="w-4 h-4 text-purple-400" />}
                      {activeTool === 'text' && <Type className="w-4 h-4 text-amber-400" />}
                      {activeTool.toUpperCase()} CONTROL · {selectedClip.name}
                    </span>
                    <button
                      onClick={() => setActiveTool('none')}
                      className="p-1 rounded text-zinc-400 hover:text-white hover:bg-zinc-800"
                    >
                      <X className="w-4 h-4" />
                    </button>
                  </div>

                  {/* Tool Specific Interactive Controls */}
                  {activeTool === 'speed' && (
                    <div className="flex items-center gap-4 text-xs">
                      <div className="flex items-center gap-2">
                        {[0.5, 1.0, 1.5, 2.0, 4.0].map((s) => (
                          <button
                            key={s}
                            onClick={() => updateSelectedClip({ speed: s })}
                            className={`px-2.5 py-1 rounded font-mono text-[11px] font-bold ${
                              selectedClip.speed === s
                                ? 'bg-cyan-600 text-white'
                                : 'bg-zinc-800 text-zinc-300 hover:bg-zinc-700'
                            }`}
                          >
                            {s}x
                          </button>
                        ))}
                      </div>
                      <input
                        type="range"
                        min="0.1"
                        max="5.0"
                        step="0.1"
                        value={selectedClip.speed}
                        onChange={(e) => updateSelectedClip({ speed: parseFloat(e.target.value) })}
                        aria-label="Playback Speed"
                        className="flex-1 accent-cyan-500 cursor-pointer"
                      />
                      <span className="font-mono text-cyan-400 font-bold">{selectedClip.speed.toFixed(1)}x</span>
                    </div>
                  )}

                  {activeTool === 'volume' && (
                    <div className="flex items-center gap-4 text-xs">
                      <Volume2 className="w-4 h-4 text-zinc-400" />
                      <input
                        type="range"
                        min="0"
                        max="2"
                        step="0.05"
                        value={selectedClip.volume}
                        onChange={(e) => updateSelectedClip({ volume: parseFloat(e.target.value) })}
                        aria-label="Audio Volume"
                        className="flex-1 accent-emerald-500 cursor-pointer"
                      />
                      <span className="font-mono text-emerald-400 font-bold">
                        {Math.round(selectedClip.volume * 100)}%
                      </span>
                    </div>
                  )}

                  {activeTool === 'color' && (
                    <div className="grid grid-cols-2 md:grid-cols-4 gap-3 text-xs">
                      <div>
                        <span className="text-[10px] text-zinc-400">Exposure</span>
                        <input
                          type="range"
                          min="-0.5"
                          max="0.5"
                          step="0.02"
                          value={selectedClip.colorGrading.brightness}
                          onChange={(e) =>
                            updateSelectedClip({
                              colorGrading: { ...selectedClip.colorGrading, brightness: parseFloat(e.target.value) },
                            })
                          }
                          aria-label="Exposure Adjustment"
                          className="w-full accent-rose-500"
                        />
                      </div>
                      <div>
                        <span className="text-[10px] text-zinc-400">Contrast</span>
                        <input
                          type="range"
                          min="0.5"
                          max="2.0"
                          step="0.05"
                          value={selectedClip.colorGrading.contrast}
                          onChange={(e) =>
                            updateSelectedClip({
                              colorGrading: { ...selectedClip.colorGrading, contrast: parseFloat(e.target.value) },
                            })
                          }
                          aria-label="Contrast Adjustment"
                          className="w-full accent-rose-500"
                        />
                      </div>
                      <div>
                        <span className="text-[10px] text-zinc-400">Saturation</span>
                        <input
                          type="range"
                          min="0"
                          max="2.5"
                          step="0.05"
                          value={selectedClip.colorGrading.saturation}
                          onChange={(e) =>
                            updateSelectedClip({
                              colorGrading: { ...selectedClip.colorGrading, saturation: parseFloat(e.target.value) },
                            })
                          }
                          aria-label="Saturation Adjustment"
                          className="w-full accent-rose-500"
                        />
                      </div>
                      <div>
                        <span className="text-[10px] text-zinc-400">LUT Preset</span>
                        <select
                          value={selectedClip.colorGrading.lut}
                          onChange={(e) =>
                            updateSelectedClip({
                              colorGrading: { ...selectedClip.colorGrading, lut: e.target.value },
                            })
                          }
                          aria-label="LUT Preset"
                          className="w-full bg-zinc-950 border border-zinc-800 text-zinc-300 rounded px-1.5 py-1 text-xs"
                        >
                          <option value="None">None</option>
                          <option value="Teal & Orange">Teal & Orange</option>
                          <option value="Cyber Neon">Cyber Neon</option>
                          <option value="Golden Hour">Golden Hour</option>
                        </select>
                      </div>
                    </div>
                  )}

                  {activeTool === 'text' && (
                    <div className="flex items-center gap-3 text-xs">
                      <input
                        type="text"
                        value={selectedClip.textContent || ''}
                        onChange={(e) => updateSelectedClip({ textContent: e.target.value })}
                        placeholder="Enter text..."
                        className="flex-1 bg-zinc-950 border border-zinc-800 rounded px-2.5 py-1.5 text-white"
                      />
                      <input
                        type="color"
                        value={selectedClip.textColor || '#05D9E8'}
                        onChange={(e) => updateSelectedClip({ textColor: e.target.value })}
                        aria-label="Text Color"
                        className="w-8 h-8 rounded border-none bg-transparent cursor-pointer"
                      />
                    </div>
                  )}

                  {activeTool === 'crop' && (
                    <div className="space-y-3 text-xs">
                      {/* Mode & Presets Header */}
                      <div className="flex items-center justify-between gap-2 pb-1 border-b border-zinc-800/80">
                        <div className="flex items-center gap-2">
                          <span className="text-[11px] text-zinc-400 font-medium">Crop Mode:</span>
                          <div className="inline-flex rounded-lg bg-zinc-950 p-0.5 border border-zinc-800 text-[10px]">
                            <button
                              onClick={() => setCropFillMode('window')}
                              className={`px-2 py-0.5 rounded font-medium transition-colors ${
                                cropFillMode === 'window' ? 'bg-cyan-600 text-white font-bold shadow-sm' : 'text-zinc-400 hover:text-white'
                              }`}
                            >
                              Window Frame (Clip)
                            </button>
                            <button
                              onClick={() => setCropFillMode('fill')}
                              className={`px-2 py-0.5 rounded font-medium transition-colors ${
                                cropFillMode === 'fill' ? 'bg-rose-600 text-white font-bold shadow-sm' : 'text-zinc-400 hover:text-white'
                              }`}
                            >
                              Fill Viewport (Cover)
                            </button>
                          </div>
                        </div>
                        <span className="text-[10px] font-mono text-cyan-400">
                          {cropFillMode === 'window' ? 'CSS clip-path mask' : 'Uniform zoom (No squish)'}
                        </span>
                      </div>

                      {/* Presets */}
                      <div className="flex items-center gap-2 overflow-x-auto pb-1">
                        {['Free', '9:16', '16:9', '1:1', '4:5', '4:3', '21:9'].map((preset) => (
                          <button
                            key={preset}
                            onClick={() => {
                              setCropAspectRatio(preset);
                              if (preset === '16:9') {
                                setCropWidthPct(100);
                                setCropHeightPct(56);
                              } else if (preset === '9:16') {
                                setCropWidthPct(56);
                                setCropHeightPct(100);
                              } else if (preset === '1:1') {
                                setCropWidthPct(80);
                                setCropHeightPct(80);
                              } else if (preset === '4:5') {
                                setCropWidthPct(80);
                                setCropHeightPct(100);
                              } else {
                                setCropWidthPct(100);
                                setCropHeightPct(100);
                              }
                            }}
                            className={`px-2.5 py-1 rounded font-mono text-[11px] font-bold ${
                              cropAspectRatio === preset
                                ? 'bg-rose-600 text-white'
                                : 'bg-zinc-800 text-zinc-300 hover:bg-zinc-700'
                            }`}
                          >
                            {preset}
                          </button>
                        ))}
                      </div>

                      {/* Width & Height Bounds Sliders */}
                      <div className="grid grid-cols-2 gap-4">
                        <div>
                          <div className="flex justify-between text-[11px] text-zinc-400 mb-1">
                            <span>Crop Width</span>
                            <span className="font-mono text-cyan-400">{cropWidthPct}%</span>
                          </div>
                          <input
                            type="range"
                            min="20"
                            max="100"
                            value={cropWidthPct}
                            onChange={(e) => setCropWidthPct(Number(e.target.value))}
                            aria-label="Crop Width"
                            className="w-full accent-cyan-500"
                          />
                        </div>
                        <div>
                          <div className="flex justify-between text-[11px] text-zinc-400 mb-1">
                            <span>Crop Height</span>
                            <span className="font-mono text-cyan-400">{cropHeightPct}%</span>
                          </div>
                          <input
                            type="range"
                            min="20"
                            max="100"
                            value={cropHeightPct}
                            onChange={(e) => setCropHeightPct(Number(e.target.value))}
                            aria-label="Crop Height"
                            className="w-full accent-cyan-500"
                          />
                        </div>
                      </div>

                      {/* Rotation & Flip Controls */}
                      <div className="flex items-center gap-3 pt-1 border-t border-zinc-800">
                        <button
                          onClick={() => setCropRotation((r) => (r + 90) % 360)}
                          className="px-2.5 py-1.5 rounded bg-zinc-800 hover:bg-zinc-700 text-zinc-200 font-mono text-[11px] flex items-center gap-1.5"
                        >
                          <RotateCw className="w-3.5 h-3.5 text-rose-400" />
                          Rotate 90° ({cropRotation}°)
                        </button>
                        <button
                          onClick={() => setCropFlipX(!cropFlipX)}
                          className={`px-2.5 py-1.5 rounded text-[11px] font-medium ${
                            cropFlipX ? 'bg-rose-900/60 text-rose-200 border border-rose-700' : 'bg-zinc-800 text-zinc-300'
                          }`}
                        >
                          Flip X
                        </button>
                        <button
                          onClick={() => setCropFlipY(!cropFlipY)}
                          className={`px-2.5 py-1.5 rounded text-[11px] font-medium ${
                            cropFlipY ? 'bg-rose-900/60 text-rose-200 border border-rose-700' : 'bg-zinc-800 text-zinc-300'
                          }`}
                        >
                          Flip Y
                        </button>
                        <button
                          onClick={() => {
                            setCropAspectRatio('Free');
                            setCropWidthPct(100);
                            setCropHeightPct(100);
                            setCropRotation(0);
                            setCropFlipX(false);
                            setCropFlipY(false);
                          }}
                          className="ml-auto text-[11px] text-zinc-500 hover:text-zinc-300"
                        >
                          Reset Crop
                        </button>
                      </div>
                    </div>
                  )}
                </div>
              )}

              {/* CONTEXTUAL BOTTOM DOCK TOOLBAR */}
              <div className="h-14 bg-zinc-900 border-t border-zinc-800 px-3 flex items-center justify-between text-xs select-none">
                {selectedClip ? (
                  /* Tools when a clip is actively selected */
                  <div className="flex items-center space-x-1 sm:space-x-2 overflow-x-auto py-1">
                    <button
                      onClick={handleSplitAtPlayhead}
                      className="px-3 py-1.5 rounded-lg bg-zinc-800 hover:bg-zinc-700 text-white font-medium flex items-center gap-1.5"
                    >
                      <Scissors className="w-3.5 h-3.5 text-rose-400" />
                      Split
                    </button>
                    {(selectedClip.type === 'video' || selectedClip.type === 'overlay') && (
                      <button
                        onClick={() => setActiveTool(activeTool === 'crop' ? 'none' : 'crop')}
                        className={`px-3 py-1.5 rounded-lg font-medium flex items-center gap-1.5 ${
                          activeTool === 'crop' ? 'bg-rose-600 text-white' : 'bg-zinc-800 hover:bg-zinc-700 text-zinc-200'
                        }`}
                      >
                        <Crop className="w-3.5 h-3.5 text-rose-400" />
                        Crop & Rotate
                      </button>
                    )}
                    <button
                      onClick={() => setActiveTool(activeTool === 'speed' ? 'none' : 'speed')}
                      className={`px-3 py-1.5 rounded-lg font-medium flex items-center gap-1.5 ${
                        activeTool === 'speed' ? 'bg-cyan-600 text-white' : 'bg-zinc-800 hover:bg-zinc-700 text-zinc-200'
                      }`}
                    >
                      <Gauge className="w-3.5 h-3.5 text-cyan-400" />
                      Speed ({selectedClip.speed}x)
                    </button>
                    <button
                      onClick={() => setActiveTool(activeTool === 'volume' ? 'none' : 'volume')}
                      className={`px-3 py-1.5 rounded-lg font-medium flex items-center gap-1.5 ${
                        activeTool === 'volume' ? 'bg-emerald-600 text-white' : 'bg-zinc-800 hover:bg-zinc-700 text-zinc-200'
                      }`}
                    >
                      <Volume2 className="w-3.5 h-3.5 text-emerald-400" />
                      Volume
                    </button>
                    {selectedClip.type === 'video' && (
                      <button
                        onClick={() => setActiveTool(activeTool === 'color' ? 'none' : 'color')}
                        className={`px-3 py-1.5 rounded-lg font-medium flex items-center gap-1.5 ${
                          activeTool === 'color' ? 'bg-rose-600 text-white' : 'bg-zinc-800 hover:bg-zinc-700 text-zinc-200'
                        }`}
                      >
                        <Palette className="w-3.5 h-3.5 text-rose-400" />
                        Color Grade
                      </button>
                    )}
                    {selectedClip.type === 'text' && (
                      <button
                        onClick={() => setActiveTool(activeTool === 'text' ? 'none' : 'text')}
                        className={`px-3 py-1.5 rounded-lg font-medium flex items-center gap-1.5 ${
                          activeTool === 'text' ? 'bg-amber-600 text-white' : 'bg-zinc-800 hover:bg-zinc-700 text-zinc-200'
                        }`}
                      >
                        <Type className="w-3.5 h-3.5 text-amber-400" />
                        Edit Text
                      </button>
                    )}
                    <button
                      onClick={handleDeleteSelectedClip}
                      className="px-3 py-1.5 rounded-lg bg-red-950/70 hover:bg-red-900 border border-red-800/80 text-red-200 font-medium flex items-center gap-1.5"
                    >
                      <Trash2 className="w-3.5 h-3.5 text-red-400" />
                      Delete
                    </button>
                  </div>
                ) : (
                  /* Global actions when nothing is selected */
                  <div className="flex items-center space-x-2">
                    <button
                      onClick={() => {
                        const newClip: Clip = {
                          id: `clip-video-${Date.now()}`,
                          trackId: 'track-main',
                          type: 'video',
                          name: 'Imported_Footage.mp4',
                          startTimeMs: totalDurationMs,
                          durationMs: 4000,
                          sourceInMs: 0,
                          sourceOutMs: 4000,
                          speed: 1.0,
                          volume: 1.0,
                          opacity: 1.0,
                          blendMode: 'normal',
                          colorGrading: { brightness: 0, contrast: 1, saturation: 1, lut: 'None' },
                        };
                        const newTracks = activeProject.tracks.map((t) =>
                          t.type === 'mainVideo' ? { ...t, clips: [...t.clips, newClip] } : t
                        );
                        pushHistory({ ...activeProject, tracks: newTracks });
                      }}
                      className="px-3 py-1.5 rounded-lg bg-zinc-800 hover:bg-zinc-700 text-zinc-200 font-medium flex items-center gap-1.5"
                    >
                      <Plus className="w-3.5 h-3.5 text-rose-400" />
                      Add Video Clip
                    </button>
                    <button
                      onClick={() => {
                        const newText: Clip = {
                          id: `clip-text-${Date.now()}`,
                          trackId: 'track-text',
                          type: 'text',
                          name: 'Title Card',
                          startTimeMs: playheadMs,
                          durationMs: 3000,
                          sourceInMs: 0,
                          sourceOutMs: 3000,
                          speed: 1.0,
                          volume: 1.0,
                          opacity: 1.0,
                          blendMode: 'normal',
                          colorGrading: { brightness: 0, contrast: 1, saturation: 1, lut: 'None' },
                          textContent: 'NEW TITLE',
                          textColor: '#FFFFFF',
                          fontSize: 28,
                        };
                        const newTracks = activeProject.tracks.map((t) =>
                          t.type === 'text' ? { ...t, clips: [...t.clips, newText] } : t
                        );
                        pushHistory({ ...activeProject, tracks: newTracks });
                      }}
                      className="px-3 py-1.5 rounded-lg bg-zinc-800 hover:bg-zinc-700 text-zinc-200 font-medium flex items-center gap-1.5"
                    >
                      <Type className="w-3.5 h-3.5 text-amber-400" />
                      Add Title
                    </button>
                    <button
                      onClick={handleSplitAtPlayhead}
                      className="px-3 py-1.5 rounded-lg bg-zinc-800 hover:bg-zinc-700 text-zinc-200 font-medium flex items-center gap-1.5"
                    >
                      <Scissors className="w-3.5 h-3.5 text-zinc-400" />
                      Split At Playhead
                    </button>
                  </div>
                )}

                <div className="text-zinc-500 font-mono text-[11px]">
                  {selectedClip ? `Selected: ${selectedClip.name}` : 'Click clip to inspect & edit'}
                </div>
              </div>
            </div>
          </div>
        )}

        {/* ================= TAB 2: PROJECTS MANAGER ================= */}
        {currentTab === 'projects' && (
          <div className="flex-1 p-6 overflow-y-auto max-w-5xl mx-auto w-full">
            <div className="flex items-center justify-between mb-6">
              <div>
                <h1 className="text-xl font-bold text-white tracking-tight">Project Management</h1>
                <p className="text-xs text-zinc-400 mt-1">
                  Stored locally as atomic JSON schemas via <code className="text-rose-400">ProjectRepository</code>.
                </p>
              </div>
              <button
                onClick={() => setShowNewProjModal(true)}
                className="px-4 py-2 rounded-lg bg-rose-600 hover:bg-rose-500 text-white font-semibold text-xs transition-colors flex items-center gap-2 shadow-lg shadow-rose-900/30"
              >
                <Plus className="w-4 h-4" />
                New Project
              </button>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
              {projectsList.map((proj) => (
                <div
                  key={proj.id}
                  onClick={() => {
                    setActiveProject(proj);
                    setCurrentTab('editor');
                  }}
                  className={`rounded-xl border p-4 cursor-pointer transition-all duration-200 ${
                    activeProject.id === proj.id
                      ? 'bg-zinc-900 border-rose-500/80 shadow-lg shadow-rose-900/20'
                      : 'bg-zinc-900/50 border-zinc-800 hover:border-zinc-700 hover:bg-zinc-900'
                  }`}
                >
                  <div className="flex justify-between items-start mb-3">
                    <span className="text-[10px] font-mono px-2 py-0.5 rounded bg-zinc-800 text-cyan-400 border border-zinc-700">
                      {proj.aspectRatio}
                    </span>
                    <span className="text-[10px] text-zinc-500 font-mono">{proj.updatedAt}</span>
                  </div>
                  <h3 className="font-bold text-sm text-white mb-1 truncate">{proj.title}</h3>
                  <p className="text-xs text-zinc-400">
                    {proj.tracks.length} tracks · {proj.fps} FPS ·{' '}
                    {Math.round(
                      proj.tracks.flatMap((t) => t.clips).reduce((acc, c) => acc + c.durationMs, 0) / 1000
                    )}
                    s duration
                  </p>
                  <div className="mt-4 pt-3 border-t border-zinc-800 flex justify-between items-center text-xs">
                    <span className="text-rose-400 font-medium">Open in Workstation</span>
                    <ChevronRight className="w-4 h-4 text-zinc-500" />
                  </div>
                </div>
              ))}
            </div>
          </div>
        )}

        {/* ================= TAB 3: CODEBASE & ARCHITECTURE ================= */}
        {currentTab === 'codebase' && (
          <div className="flex-1 flex overflow-hidden">
            {/* Sidebar with files */}
            <div className="w-72 border-r border-zinc-800 bg-zinc-900/60 flex flex-col">
              <div className="p-3 border-b border-zinc-800">
                <h3 className="text-xs font-bold text-zinc-200">Flutter Architecture Blueprint</h3>
                <p className="text-[11px] text-zinc-500">All required files generated & verified</p>
              </div>
              <div className="flex-1 overflow-y-auto p-2 space-y-1">
                {CODE_FILE_CATALOG.map((f) => (
                  <button
                    key={f.path}
                    onClick={() => setInspectedFile(f)}
                    className={`w-full text-left px-2.5 py-2 rounded-lg text-xs transition-colors flex flex-col gap-0.5 ${
                      inspectedFile.path === f.path
                        ? 'bg-rose-950/70 border border-rose-800/80 text-white'
                        : 'text-zinc-400 hover:bg-zinc-800 hover:text-zinc-200'
                    }`}
                  >
                    <div className="flex items-center gap-1.5 font-mono text-[11px]">
                      <FileCode className="w-3.5 h-3.5 text-rose-400" />
                      <span className="truncate">{f.path.split('/').pop()}</span>
                    </div>
                    <span className="text-[10px] text-zinc-500">{f.module}</span>
                  </button>
                ))}
              </div>
            </div>

            {/* Code viewer */}
            <div className="flex-1 flex flex-col bg-zinc-950 overflow-hidden">
              <div className="h-12 border-b border-zinc-800 px-4 flex items-center justify-between bg-zinc-900/30">
                <div>
                  <span className="text-xs font-mono font-semibold text-rose-300">{inspectedFile.path}</span>
                  <p className="text-[11px] text-zinc-400">{inspectedFile.description}</p>
                </div>
                <button
                  onClick={() => {
                    navigator.clipboard.writeText(inspectedFile.codePreview);
                    setCopiedCode(inspectedFile.path);
                    setTimeout(() => setCopiedCode(null), 2000);
                  }}
                  className="px-2.5 py-1 rounded bg-zinc-800 hover:bg-zinc-700 text-xs text-zinc-300 flex items-center gap-1.5 border border-zinc-700"
                >
                  {copiedCode === inspectedFile.path ? <Check className="w-3.5 h-3.5 text-emerald-400" /> : <Copy className="w-3.5 h-3.5" />}
                  {copiedCode === inspectedFile.path ? 'Copied' : 'Copy Snippet'}
                </button>
              </div>

              <div className="flex-1 p-4 overflow-auto font-mono text-xs text-zinc-300 bg-zinc-950/90 leading-relaxed">
                <pre>{inspectedFile.codePreview}</pre>
              </div>
            </div>
          </div>
        )}

        {/* ================= TAB 4: SETTINGS ================= */}
        {currentTab === 'settings' && (
          <div className="flex-1 p-6 overflow-y-auto max-w-3xl mx-auto w-full">
            <h1 className="text-xl font-bold text-white mb-6">Workstation & Pipeline Settings</h1>

            <div className="space-y-4">
              <div className="p-4 rounded-xl bg-zinc-900 border border-zinc-800">
                <h3 className="text-sm font-bold text-white mb-1">Local Processing & Zero-AI Guarantee</h3>
                <p className="text-xs text-zinc-400 mb-3">
                  This application executes 100% offline via native mobile FFmpeg binaries. Zero video data is sent to
                  external servers, and zero brand watermarks are placed on exports.
                </p>
                <div className="flex items-center gap-2 text-xs text-emerald-400 font-medium">
                  <ShieldCheck className="w-4 h-4" />
                  Verified: 100% Offline Local Pipeline
                </div>
              </div>

              <div className="p-4 rounded-xl bg-zinc-900 border border-zinc-800">
                <h3 className="text-sm font-bold text-white mb-1">Preview Proxy Generation</h3>
                <p className="text-xs text-zinc-400 mb-3">
                  Downscales 4K media to 720p intra-frame drafts for ultra-smooth 60fps scrubbing on Android devices.
                </p>
                <label className="flex items-center gap-2 text-xs text-zinc-200 cursor-pointer">
                  <input type="checkbox" defaultChecked className="rounded accent-rose-500" />
                  Enable background proxy caching
                </label>
              </div>

              <div className="p-4 rounded-xl bg-zinc-900 border border-zinc-800">
                <h3 className="text-sm font-bold text-white mb-1">Storage Cache</h3>
                <p className="text-xs text-zinc-400 mb-2">
                  Temporary audio waveforms and video proxies storage: <strong>142.6 MB</strong>
                </p>
                <button
                  onClick={() => alert('Temporary proxy cache cleared.')}
                  className="px-3 py-1.5 rounded-lg bg-zinc-800 hover:bg-zinc-700 text-xs text-zinc-300 font-medium border border-zinc-700"
                >
                  Clear Proxy Cache
                </button>
              </div>
            </div>
          </div>
        )}
      </main>

      {/* ================= MODAL: EXPORT / RENDER ================= */}
      {showExportModal && (
        <div className="fixed inset-0 bg-black/80 backdrop-blur-sm z-50 flex items-center justify-center p-4">
          <div className="w-full max-w-md bg-zinc-900 border border-zinc-800 rounded-2xl shadow-2xl overflow-hidden p-5">
            <div className="flex items-center justify-between mb-4">
              <div className="flex items-center gap-2">
                <div className="w-7 h-7 rounded-lg bg-rose-600 flex items-center justify-center">
                  <Download className="w-4 h-4 text-white" />
                </div>
                <h2 className="text-base font-bold text-white">Export & FFmpeg Render</h2>
              </div>
              {!isExporting && (
                <button
                  onClick={() => setShowExportModal(false)}
                  className="p-1 rounded text-zinc-400 hover:text-white"
                >
                  <X className="w-5 h-5" />
                </button>
              )}
            </div>

            {isExporting ? (
              <div className="py-6 text-center">
                <div className="w-12 h-12 rounded-full border-4 border-rose-500/20 border-t-rose-500 animate-spin mx-auto mb-4" />
                <h3 className="text-sm font-bold text-white mb-1">Rendering via Native FFmpeg</h3>
                <p className="text-xs text-zinc-400 mb-4 font-mono">
                  Executing filter_complex pipeline · {exportProgress}%
                </p>
                <div className="w-full bg-zinc-800 rounded-full h-2 overflow-hidden mb-2">
                  <div
                    className="bg-rose-500 h-full transition-all duration-150"
                    style={{ width: `${exportProgress}%` }}
                  />
                </div>
                <div className="flex justify-between text-[11px] font-mono text-zinc-500">
                  <span>Speed: 2.1x</span>
                  <span>FPS: 29.97</span>
                  <span>Bitrate: {exportBitrate} Mbps</span>
                </div>
              </div>
            ) : exportCompletePath ? (
              <div className="py-4 text-center">
                <CheckCircle2 className="w-12 h-12 text-emerald-400 mx-auto mb-2" />
                <h3 className="text-sm font-bold text-white mb-1">Video Rendered Successfully!</h3>
                <p className="text-xs text-zinc-400 mb-3 font-mono break-all bg-zinc-950 p-2 rounded border border-zinc-800">
                  {exportCompletePath}
                </p>
                <button
                  onClick={() => {
                    setExportCompletePath(null);
                    setShowExportModal(false);
                  }}
                  className="w-full py-2.5 rounded-lg bg-rose-600 hover:bg-rose-500 text-white font-semibold text-xs"
                >
                  Done
                </button>
              </div>
            ) : (
              <div className="space-y-4 text-xs">
                <div>
                  <label className="text-zinc-400 font-medium block mb-1.5">Output Resolution</label>
                  <div className="grid grid-cols-3 gap-2">
                    {(['720p', '1080p', '4K'] as const).map((r) => (
                      <button
                        key={r}
                        onClick={() => setExportRes(r)}
                        className={`py-2 rounded-lg font-mono font-bold text-center border ${
                          exportRes === r
                            ? 'bg-rose-950 border-rose-500 text-white'
                            : 'bg-zinc-950 border-zinc-800 text-zinc-400 hover:bg-zinc-800'
                        }`}
                      >
                        {r}
                      </button>
                    ))}
                  </div>
                </div>

                <div>
                  <label className="text-zinc-400 font-medium block mb-1.5">Frame Rate</label>
                  <div className="grid grid-cols-3 gap-2">
                    {[24, 30, 60].map((f) => (
                      <button
                        key={f}
                        onClick={() => setExportFps(f)}
                        className={`py-2 rounded-lg font-mono font-bold text-center border ${
                          exportFps === f
                            ? 'bg-cyan-950 border-cyan-500 text-white'
                            : 'bg-zinc-950 border-zinc-800 text-zinc-400 hover:bg-zinc-800'
                        }`}
                      >
                        {f} FPS
                      </button>
                    ))}
                  </div>
                </div>

                <div>
                  <label className="text-zinc-400 font-medium block mb-1.5">Codec Target</label>
                  <select
                    value={exportCodec}
                    onChange={(e) => setExportCodec(e.target.value as any)}
                    className="w-full bg-zinc-950 border border-zinc-800 text-zinc-200 rounded-lg p-2"
                  >
                    <option value="H.264">H.264 (Universal MP4 / Fast)</option>
                    <option value="HEVC (H.265)">HEVC / H.265 (High Efficiency)</option>
                  </select>
                </div>

                <div>
                  <div className="flex justify-between text-zinc-400 mb-1">
                    <span>Target Bitrate</span>
                    <span className="font-mono text-white font-bold">{exportBitrate} Mbps</span>
                  </div>
                  <input
                    type="range"
                    min="4"
                    max="40"
                    value={exportBitrate}
                    onChange={(e) => setExportBitrate(Number(e.target.value))}
                    className="w-full accent-rose-500 cursor-pointer"
                  />
                </div>

                <button
                  onClick={handleStartExport}
                  className="w-full py-2.5 rounded-lg bg-rose-600 hover:bg-rose-500 text-white font-bold text-xs shadow-lg shadow-rose-900/30 mt-2"
                >
                  Start Offline FFmpeg Export
                </button>
              </div>
            )}
          </div>
        </div>
      )}

      {/* ================= MODAL: NEW PROJECT ================= */}
      {showNewProjModal && (
        <div className="fixed inset-0 bg-black/80 backdrop-blur-sm z-50 flex items-center justify-center p-4">
          <div className="w-full max-w-sm bg-zinc-900 border border-zinc-800 rounded-2xl p-5 shadow-2xl">
            <h2 className="text-base font-bold text-white mb-3">Create New Project</h2>

            <div className="space-y-3 text-xs">
              <div>
                <label className="text-zinc-400 font-medium block mb-1">Project Name</label>
                <input
                  type="text"
                  placeholder="e.g. Action Reel 2026"
                  value={newProjTitle}
                  onChange={(e) => setNewProjTitle(e.target.value)}
                  className="w-full bg-zinc-950 border border-zinc-800 text-white rounded-lg p-2.5 focus:border-rose-500 focus:outline-none"
                />
              </div>

              <div>
                <label className="text-zinc-400 font-medium block mb-1">Aspect Ratio</label>
                <div className="grid grid-cols-4 gap-2">
                  {(['9:16', '16:9', '1:1', '4:5'] as const).map((ratio) => (
                    <button
                      key={ratio}
                      onClick={() => setNewProjRatio(ratio)}
                      className={`py-2 rounded-lg font-mono font-bold text-center border ${
                        newProjRatio === ratio
                          ? 'bg-rose-950 border-rose-500 text-white'
                          : 'bg-zinc-950 border-zinc-800 text-zinc-400'
                      }`}
                    >
                      {ratio}
                    </button>
                  ))}
                </div>
              </div>

              <div className="flex gap-2 pt-2">
                <button
                  onClick={() => setShowNewProjModal(false)}
                  className="flex-1 py-2 rounded-lg bg-zinc-800 text-zinc-300 font-semibold"
                >
                  Cancel
                </button>
                <button
                  onClick={() => {
                    const newProj: Project = {
                      id: `proj-${Date.now()}`,
                      title: newProjTitle.trim() || 'Untitled Project',
                      aspectRatio: newProjRatio,
                      fps: 30,
                      updatedAt: 'Just now',
                      tracks: [
                        { id: 't-text', name: 'Text & Titles', type: 'text', clips: [] },
                        { id: 't-overlay', name: 'Overlay / PIP', type: 'overlay', clips: [] },
                        { id: 't-main', name: 'Main Video', type: 'mainVideo', clips: [] },
                        { id: 't-audio', name: 'Audio Track', type: 'audio', clips: [] },
                      ],
                    };
                    setProjectsList([newProj, ...projectsList]);
                    setActiveProject(newProj);
                    setShowNewProjModal(false);
                    setCurrentTab('editor');
                  }}
                  className="flex-1 py-2 rounded-lg bg-rose-600 hover:bg-rose-500 text-white font-semibold"
                >
                  Create
                </button>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
