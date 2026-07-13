import { ref, watch, onMounted } from 'vue';

export function useSound() {
  const soundEnabled = ref<boolean>(true);
  let ctx: AudioContext | null = null;

  const initCtx = (): void => {
    if (!ctx) {
      try {
        const AudioContextClass = window.AudioContext || (window as any).webkitAudioContext;
        if (AudioContextClass) {
          ctx = new AudioContextClass();
        }
      } catch (e) {
        console.warn('Web Audio API not supported:', e);
      }
    }
  };

  const playTone = (freq: number, type: OscillatorType, duration: number, ramp = false): void => {
    if (!soundEnabled.value) return;
    initCtx();
    if (!ctx) return;

    try {
      const osc = ctx.createOscillator();
      const gain = ctx.createGain();

      osc.type = type;
      osc.frequency.setValueAtTime(freq, ctx.currentTime);
      if (ramp) {
        osc.frequency.exponentialRampToValueAtTime(freq * 3, ctx.currentTime + duration);
      }

      gain.gain.setValueAtTime(0.1, ctx.currentTime);
      gain.gain.exponentialRampToValueAtTime(0.01, ctx.currentTime + duration);

      osc.connect(gain);
      gain.connect(ctx.destination);

      osc.start();
      osc.stop(ctx.currentTime + duration);
    } catch (e) {
      console.warn('Audio playback failed', e)
    }
  };

  const playClick = (): void => playTone(800, 'square', 0.08);
  const playTick = (): void => playTone(600, 'square', 0.03);
  const playResult = (): void => playTone(400, 'square', 0.2, true);

  onMounted(() => {
    try {
      const saved = localStorage.getItem('eatwhat-sound');
      soundEnabled.value = saved === null ? true : saved === 'true';
    } catch (e) {
      soundEnabled.value = true;
    }
  });

  watch(soundEnabled, (val) => {
    try {
      localStorage.setItem('eatwhat-sound', val.toString());
    } catch (e) {
      console.error('Failed to persist sound preference', e)
    }
  });

  return { soundEnabled, playClick, playTick, playResult };
}
