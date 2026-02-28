import { d as defineEventHandler, e as useRuntimeConfig } from '../../_/nitro.mjs';
import 'node:http';
import 'node:https';
import 'node:events';
import 'node:buffer';
import 'node:fs';
import 'node:path';
import 'node:crypto';

const test = defineEventHandler((event) => {
  var _a, _b;
  const config = useRuntimeConfig();
  return {
    message: "Test API working",
    timestamp: (/* @__PURE__ */ new Date()).toISOString(),
    env: {
      hasSupabaseUrl: !!config.supabaseUrl,
      hasSupabaseServiceKey: !!config.supabaseServiceKey,
      supabaseUrlLength: ((_a = config.supabaseUrl) == null ? void 0 : _a.length) || 0,
      serviceKeyLength: ((_b = config.supabaseServiceKey) == null ? void 0 : _b.length) || 0,
      hasPublicSupabaseUrl: !!config.public.supabaseUrl,
      hasPublicAnonKey: !!config.public.supabaseAnonKey
    }
  };
});

export { test as default };
//# sourceMappingURL=test.mjs.map
