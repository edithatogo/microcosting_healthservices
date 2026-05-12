import { describe, expect, it } from 'vitest';

import { createWasmAdapter, WasmAdapterError } from '../src/index.js';

describe('createWasmAdapter', () => {
  it('unwraps a wasm-pack-style default initializer and freezes the boundary', async () => {
    const handle = await createWasmAdapter({
      moduleFactory: () => ({
        default: () => ({
          version: '0.0.0',
          calculate: (payload: unknown) => payload,
        }),
      }),
      validateExports: (
        candidate,
      ): candidate is {
        readonly version: string;
        readonly calculate: (payload: unknown) => unknown;
      } => {
        if (typeof candidate !== 'object' || candidate === null) {
          return false;
        }

        const record = candidate as Record<string, unknown>;
        return (
          typeof record.version === 'string' &&
          typeof record.calculate === 'function'
        );
      },
    });

    expect(handle.exports.version).toBe('0.0.0');
    await expect(handle.ready).resolves.toMatchObject({ version: '0.0.0' });
  });

  it('fails closed when the module surface does not match', async () => {
    await expect(
      createWasmAdapter({
        moduleFactory: () => ({ default: () => ({}) }),
        validateExports: (_candidate): _candidate is never => false,
      }),
    ).rejects.toBeInstanceOf(WasmAdapterError);
  });
});
