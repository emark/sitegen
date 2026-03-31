# Sitegen - Static Site Generator

A Perl static site generator using Mojolicious and SQLite.

## Requirements

- Perl 5.30+
- SQLite3
- DBIx::Custom
- Mojolicious 9.39+

## Installation

### 1. Install Perl Dependencies

```bash
cpanm --installdeps .
```

Or with system packages (Debian/Ubuntu):
```bash
apt-get install libdbd-sqlite3-perl libmojolicious-perl
```

### 2. Configure Application

Copy the development configuration:

```bash
cp -sf devcfg/dev.sitegen.conf sitegen.conf
```

Or for other environments:
```bash
cp -sf devcfg/emark.sitegen.conf sitegen.conf
cp -sf devcfg/web.sitegen.conf sitegen.conf
```

### 3. Database Setup

Ensure the SQLite database exists at the path specified in your config (e.g., `db/dev.sql`).

## Running the Application

### Development Mode (with auto-reload)

```bash
morbo script/sitegen
```

The app will be available at `http://localhost:3000`

### Production Mode

```bash
./script/sitegen daemon
```

### Docker Deployment

Build the image:
```bash
docker build -t sitegen .
```

Run the container:
```bash
docker run -itd -p 80:3000 \
  --mount type=bind,src=${PWD}/sitegen.conf,dst=/sitegen/sitegen.conf \
  --mount type=bind,src=${PWD}/public/downloads,dst=/sitegen/public/downloads \
  --mount type=bind,src=${PWD}/db,dst=/sitegen/db \
  sitegen
```

## Configuration

Edit `sitegen.conf` to configure:

| Parameter | Description |
|-----------|-------------|
| `dsn` | SQLite database connection string |
| `login` / `pass` | Admin credentials |
| `prefix` | Table prefix |
| `sitename` | Site identifier |
| `url` | Public URL |
| `downloads` | Path to downloads directory |
| `static` | Static files output directory |
| `static_extension` | File extension for generated pages |

## Admin Panel

Access the admin interface at `/admin/` with credentials from config.

## Testing

```bash
prove -Ilib t/
```

Or run a single test:
```bash
perl -Ilib t/basic.t
```

## Project Structure

```
sitegen/
├── lib/
│   ├── Sitegen.pm                    # Main application
│   └── Sitegen/Controller/           # Controllers
├── templates/                         # Mojolicious templates
├── public/                           # Static assets
├── db/                               # SQLite databases
├── script/sitegen                    # Entry point
├── sitegen.conf                      # Runtime config
└── docs/                            # Documentation
```