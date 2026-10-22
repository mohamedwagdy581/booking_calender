declare module "https://esm.sh/@supabase/supabase-js@2" {
  // Loose editor stub; the real types come from esm.sh at deploy time.
  // deno-lint-ignore no-explicit-any
  export function createClient(url: string, key: string, options?: unknown): any;
}

declare const Deno: {
  env: {
    get: (key: string) => string | undefined;
  };
};
