CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE IF NOT EXISTS todo (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id TEXT NOT NULL,
  title TEXT NOT NULL,
  description TEXT DEFAULT '',
  completed BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  due_date TIMESTAMPTZ,
  priority INTEGER,
  tags TEXT[],
  search_vector TSVECTOR
);

-- Create trigger function
CREATE OR REPLACE FUNCTION update_search_vector() RETURNS trigger AS $$
BEGIN
  NEW.search_vector := to_tsvector(
    'simple',
    coalesce(NEW.title, '') || ' ' ||
    coalesce(NEW.description, '') || ' ' ||
    array_to_string(NEW.tags, ' ')
  );
  RETURN NEW;
END
$$ LANGUAGE plpgsql IMMUTABLE;

-- Attach trigger
CREATE TRIGGER trg_update_search_vector
BEFORE INSERT OR UPDATE ON todo
FOR EACH ROW EXECUTE FUNCTION update_search_vector();

-- Index
CREATE INDEX IF NOT EXISTS todo_user_idx ON todo (user_id);
CREATE INDEX IF NOT EXISTS todo_search_idx ON todo USING GIN (search_vector);

SELECT '✅ init done (with trigger)' AS status;
