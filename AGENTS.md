# AGENTS.md - Sitegen Development Guide

Sitegen is a Perl static site generator using Mojolicious 9.39 and SQLite via DBIx::Custom.

## Build, Test & Run Commands

### Install Dependencies
```bash
cpanm --installdeps .
```

### Running the Application
```bash
# Development server (auto-reloads on changes)
morbo script/sitegen

# Production mode
./script/sitegen daemon
```

### Running Tests
```bash
# Run all tests
prove -Ilib t/

# Run a single test file
perl -Ilib t/basic.t
prove -Ilib t/basic.t
```

### Docker
```bash
docker build -t sitegen .
docker run -itd -p 80:3000 --mount type=bind,src=${PWD}/sitegen.conf,dst=/sitegen/sitegen.conf --mount type=bind,src=${PWD}/public/downloads,dst=/sitegen/public/downloads --mount type=bind,src=${PWD}/db,dst=/sitegen/db sitegen
```

---

## Code Style Guidelines

### Import Conventions
```perl
# Application main module
use Mojo::Base 'Mojolicious', -base, -signatures;

# Controllers
use Mojo::Base 'Mojolicious::Controller';

# Database
use DBIx::Custom;

use feature qw(say state);
use utf8;
```

### Formatting
- Use tabs for indentation
- Opening brace on same line
- Max line length: 120 characters (soft)
- Use blank lines between logical sections

### Naming Conventions
- **Packages**: Capitalize each word (`Sitegen::Controller::Admin`)
- **Methods**: snake_case (`sub login`, `sub dashboard`)
- **Variables**: snake_case (`$config`, `$downloads`)
- **Constants**: SCREAMING_SNAKE_CASE (`my $VERSION = 'v1.10'`)

### Package Structure
```perl
package Sitegen::Controller::Admin;
use Mojo::Base 'Mojolicious::Controller';

my $VERSION = 'v1.10';

has 'login' => sub {
    my $self = shift;
    return $self->session->{auth} ? 1 : $self->redirect_to('/admin/');
};

sub auth { ... }
sub dashboard { ... }

1;
```

### Error Handling
```perl
# Fatal errors
open my $fh, "<", $file or die "Can't open $file: $!";

# Non-fatal warnings
unlink $file or warn "Couldn't delete file: $!";

# Structured results
my $alert = { type => 'success', text => "Page created" };
```

### Controller Patterns
```perl
# Route to controller#action
$r->any('/admin/')->to('admin#auth');
$r->post('/admin/p/add/')->to('admin#add');

# Authentication
sub dashboard {
    my $self = shift;
    $self->login;
    # ... proceed
}

# Database access
my $pages = $self->app->dbh->select(
    table => $config->{prefix} . $config->{sitename},
    column => ['url'],
    where => {url => $url},
)->fetch_hash;
```

### Database Config
```perl
has 'dbh' => sub {
    my $self = shift;
    my $config = $self->app->config;
    return DBIx::Custom->connect(
        dsn => $config->{dsn},
        user => $config->{dbuser},
        password => $config->{dbpassword},
        option => {sqlite_unicode => 1}
    );
};
```

---

## Project Structure
```
sitegen/
├── lib/
│   ├── Sitegen.pm                 # Main application
│   └── Sitegen/Controller/        # Controllers (Admin, Generate, Photo, Rentals)
├── t/basic.t                     # Test suite
├── script/sitegen                # Entry point
├── templates/                    # Mojolicious templates
├── db/                           # SQLite database
└── sitegen.conf                  # Runtime config
```

---

## Testing Guidelines
Use Test::Mojo for controller/route testing:
```perl
my $t = Test::Mojo->new('Sitegen');

$t->post_ok('/admin/p/add/' => form => {url => 'test'})
  ->status_is(302)
  ->header_is(location => '/admin/dashboard/');
```
