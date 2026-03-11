declare module "https://deno.land/std@0.168.0/http/server.ts" {
  export function serve(
    handler: (req: Request) => Response | Promise<Response>,
  ): void;
}

declare module "https://esm.sh/@supabase/supabase-js@2" {
  export function createClient(url: string, key: string): {
    from: (table: string) => {
      select: (columns: string) => Promise<{ data: unknown; error: { message: string } | null }>;
      delete: () => {
        in: (column: string, values: string[]) => Promise<unknown>;
      };
    };
  };
}

declare const Deno: {
  env: {
    get: (key: string) => string | undefined;
  };
};
