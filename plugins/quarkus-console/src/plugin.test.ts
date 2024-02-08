import { quarkusConsolePlugin } from './plugin';

describe('quarkus-console', () => {
  it('should export plugin', () => {
    expect(quarkusConsolePlugin).toBeDefined();
  });
});
