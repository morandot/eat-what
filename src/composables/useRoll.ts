import { ref, onUnmounted } from 'vue';

export function useRoll(playTick: () => void, playResult: () => void) {
  const isRolling = ref<boolean>(false);
  const currentResult = ref<string | null>(null);
  let timer: ReturnType<typeof setTimeout> | null = null;

  const roll = (pool: readonly string[], callback?: (result: string) => void): void => {
    if (isRolling.value) return;
    isRolling.value = true;
    currentResult.value = null;

    const rounds = 15 + Math.floor(Math.random() * 8);
    let currentRound = 0;
    let delay = 80;

    const next = (): void => {
      const idx = Math.floor(Math.random() * pool.length);
      currentResult.value = pool[idx];
      playTick();

      currentRound++;
      if (currentRound < rounds) {
        if (currentRound > rounds - 5) {
          delay += 40;
        }
        timer = setTimeout(next, delay);
      } else {
        isRolling.value = false;
        playResult();
        if (callback && currentResult.value) {
          callback(currentResult.value);
        }
      }
    };

    next();
  };

  onUnmounted(() => {
    if (timer) clearTimeout(timer);
  });

  return { isRolling, currentResult, roll };
}
