import type {
  WasmAdapterConfig,
  WasmAdapterHandle,
  WasmModuleShape,
} from './types.js';

export class WasmAdapterError extends Error {
  public constructor(message: string) {
    super(message);
    this.name = 'WasmAdapterError';
  }
}

export async function createWasmAdapter<TExports extends Record<string, unknown>>(
  config: WasmAdapterConfig<TExports>,
): Promise<WasmAdapterHandle<TExports>> {
  const module = await config.moduleFactory();
  const resolvedModule = await unwrapDefaultExport(module);

  if (!config.validateExports(resolvedModule)) {
    throw new WasmAdapterError('WASM module exports do not match the adapter contract.');
  }

  const frozenExports = Object.freeze({ ...resolvedModule }) as Readonly<TExports>;
  const ready = (async () => {
    if (config.onReady) {
      await config.onReady(frozenExports);
    }

    return frozenExports;
  })();

  return {
    exports: frozenExports,
    ready,
  };
}

async function unwrapDefaultExport(module: unknown): Promise<unknown> {
  if (!isWasmModuleShape(module)) {
    return module;
  }

  const defaultExport = module.default;
  if (typeof defaultExport === 'function') {
    return await defaultExport();
  }

  if (defaultExport && typeof defaultExport === 'object') {
    return defaultExport;
  }

  return module;
}

function isWasmModuleShape(candidate: unknown): candidate is WasmModuleShape {
  return typeof candidate === 'object' && candidate !== null;
}

