# verbose_migrations

[![CI](https://github.com/keygen-sh/verbose_migrations/actions/workflows/test.yml/badge.svg)](https://github.com/keygen-sh/verbose_migrations/actions)
[![Gem Version](https://badge.fury.io/rb/verbose_migrations.svg)](https://badge.fury.io/rb/verbose_migrations)

Enable verbose logging for Active Record migrations, regardless of configured
log level. Monitor query speed, query execution, and overall progress when
executing long running or otherwise risky migrations.

This gem was extracted from [Keygen](https://keygen.sh).

Sponsored by:

<a href="https://keygen.sh?ref=verbose_migrations">
  <div>
    <img src="https://keygen.sh/images/logo-pill.png" width="200" alt="Keygen">
  </div>
</a>

_A fair source software licensing and distribution API._

## Installation

Add this line to your application's `Gemfile`:

```ruby
gem 'verbose_migrations'
```

And then execute:

```bash
$ bundle
```

Or install it yourself as:

```bash
$ gem install verbose_migrations
```

## Usage

Use the `verbose!` class method to enable debug logging. It accepts an optional log
`level:` and `logger:`.

```ruby
class SeedTagsFromPosts < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!
  verbose!

  def up
    update_count = nil
    batch_count  = 0

    until update_count == 0
      batch_count  += 1
      update_count  = exec_update(<<~SQL.squish, batch_count:, batch_size: 10_000)
        WITH batch AS (
          SELECT id, unnest(tags) AS tag_name
          FROM posts
          WHERE tags IS NOT NULL
          LIMIT :batch_size
        ), inserted_tags AS (
          INSERT INTO tags (name)
          SELECT DISTINCT tag_name
          FROM batch
          ON CONFLICT (name) DO NOTHING
          RETURNING id, name
        )
        INSERT INTO post_tags (post_id, tag_id)
        SELECT batch.id, tags.id
        FROM batch
        JOIN tags ON tags.name = batch.tag_name
        /* batch=:batch_count */
      SQL
    end
  end
end

```

Before, you have a black box:

```
== 20240817010101 SeedTagsFromPosts: migrating ================================
== 20240817010101 SeedTagsFromPosts: migrated (42.0312s) =======================
```

After, you see progress:

```
== 20240817010101 SeedTagsFromPosts: migrating ================================
==> DEBUG -- : (2.2ms) WITH batch AS ( SELECT id, unnest(tags) AS tag_name FROM posts WHERE tags IS NOT NULL LIMIT 10000 ), inserted_tags AS ( INSERT INTO tags (name) SELECT DISTINCT tag_name FROM batch ON CONFLICT (name) DO NOTHING RETURNING id, name ) INSERT INTO post_tags (post_id, tag_id) SELECT batch.id, tags.id FROM batch JOIN tags ON tags.name = batch.tag_name /* batch=1 */
==> DEBUG -- : (1.1ms) WITH batch AS ( SELECT id, unnest(tags) AS tag_name FROM posts WHERE tags IS NOT NULL LIMIT 10000 ), inserted_tags AS ( INSERT INTO tags (name) SELECT DISTINCT tag_name FROM batch ON CONFLICT (name) DO NOTHING RETURNING id, name ) INSERT INTO post_tags (post_id, tag_id) SELECT batch.id, tags.id FROM batch JOIN tags ON tags.name = batch.tag_name /* batch=2 */
==> DEBUG -- : (1.3ms) WITH batch AS ( SELECT id, unnest(tags) AS tag_name FROM posts WHERE tags IS NOT NULL LIMIT 10000 ), inserted_tags AS ( INSERT INTO tags (name) SELECT DISTINCT tag_name FROM batch ON CONFLICT (name) DO NOTHING RETURNING id, name ) INSERT INTO post_tags (post_id, tag_id) SELECT batch.id, tags.id FROM batch JOIN tags ON tags.name = batch.tag_name /* batch=3 */
==> DEBUG -- : (1.7ms) ...
== 20240817010101 SeedTagsFromPosts: migrated (42.0312s) =======================
```

## Supported Rubies

**`verbose_migrations` supports Ruby 3.1 and above.** We encourage you to upgrade
if you're on an older version. Ruby 3 provides a lot of great features, like
better pattern matching and a new shorthand hash syntax.

## Is it any good?

Yes.

## Contributing

If you have an idea, or have discovered a bug, please open an issue or create a
pull request.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
