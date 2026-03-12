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

# Run a single test file (two equivalent ways)
perl -Ilib t/basic.t
prove -Ilib t/basic.t

# Run specific test with verbose output
prove -Ilib -v t/basic.t
```

### Linting & Syntax Checking
```bash
# Syntax check all Perl files
perl -c lib/Sitegen.pm
perl -c lib/Sitegen/Controller/*.pm

# Check for undefined variables
perl -Ilib -w -c script/sitegen
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

# Features
use feature qw(say state);
use utf8;
```

### Formatting
- Use tabs for indentation
- Opening brace on same line
- Max line length: 120 characters (soft)
- Use blank lines between logical sections
- Chain method calls with indentation:
```perl
my $pages = $self->app->dbh->select(
    table => $config->{prefix} . $config->{sitename},
    column => ['url'],
    where => {url => $url},
)->fetch_hash;
```

### Naming Conventions
- **Packages**: Capitalize each word (`Sitegen::Controller::Admin`)
- **Methods**: snake_case (`sub login`, `sub dashboard`)
- **Variables**: snake_case (`$config`, `$downloads`)
- **Constants**: SCREAMING_SNAKE_CASE (`my $VERSION = 'v1.10'`)
- **File names**: Lowercase with underscores (`admin.pm`, `generate.pm`)

### Package Structure
```perl
package Sitegen::Controller::Admin;
use Mojo::Base 'Mojolicious::Controller';

my $VERSION = 'v1.10';
my $GIT = 'https://github.com/emark/sitegen/releases/latest/';

has 'login' => sub {
    my $self = shift;
    return $self->session->{auth} ? 1 : $self->redirect_to('/admin/');
};

sub auth { ... }
sub dashboard { ... }

1;
```

### Common Patterns

#### Route Definitions
```perl
sub startup {
    my $self = shift;
    my $r = $self->routes;
    
    # Static route
    $r->any('/admin/')->to('admin#auth');
    
    # With format constraint
    $r->get('/gallery' => [format => ['html']])->to('photo#gallery');
    
    # With URL regex constraint
    $r->get('/rentals/:url' => [url => qr/\d\-\d+/], [format => ['html']])->to('rentals#show');
}
```

#### Authentication Pattern
```perl
sub dashboard {
    my $self = shift;
    $self->login;  # Redirects if not authenticated
    
    my $config = $self->config;
    # ... proceed with action
}
```

#### Database Access
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

# Usage in controllers
my $urls = $self->app->dbh->select(
    table => $config->{prefix} . $config->{sitename},
    column => 'url',
)->values;
```

### Error Handling
```perl
# Fatal errors - die with message
open my $fh, "<", $file or die "Can't open $file: $!";

# File operations with checks
my $update = (-e -f -r $config->{update}) ? "Running" : "Complete";

# Non-fatal warnings
unlink $file or warn "Couldn't delete file: $!";

# Structured results for templates
my $alert = { type => 'success', text => "Page created" };
```

### Controller Patterns
```perl
# Route to controller#action
$r->any('/admin/')->to('admin#auth');
$r->post('/admin/p/add/')->to('admin#add');

# Rendering with multiple variables
$self->render(
    urls => $urls,
    update => $update,
    version => $VERSION,
    gitrepo => $GIT,
    log_upd => $log_upd,
);
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

### Basic Test Structure
```perl
use Mojo::Base -strict;
use Test::More;
use Test::Mojo;

my $t = Test::Mojo->new('Sitegen');

# Test authentication
$t->post_ok('/admin/' => form => {login => 'dev', pass => 'dev'})
  ->status_is(302)
  ->header_is(location => '/admin/dashboard/');

# Test protected route
$t->get_ok('/admin/dashboard/')
  ->status_is(200);

# Test form submission
$t->post_ok('/admin/p/add/' => form => {url => 'test'})
  ->status_is(302)
  ->header_is(location => '/admin/dashboard/');

done_testing();
```

### Test Assertions
```perl
$t->status_is(302);           # Check HTTP status
$t->header_is(location => '/admin/');  # Check redirect location
$t->text_is('#title' => 'Hello');      # Check element content
$t->get_ok('/page.html');    # GET request succeeds
$t->post_ok('/submit' => form => {...}); # POST with form data
```
