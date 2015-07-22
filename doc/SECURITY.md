Security
========

This document is intended to help our customers'
security, risk, compliance, or developer teams
evaluate what we do with our customers' code and data.

Because [Agile Season is open source][oss],
in this document we refer to portions of the application code and its dependent
libraries, frameworks, and programming languages.

[oss]: https://github.com/agileseason/agileseason

Vulnerability Reporting
-----------------------

For security inquiries or vulnerability reports, please email
<support@agileseason.com>.

agileseason
----------

Agile Season is a small team within agileseason is responsible for Agile Season.
We can't afford to hire a third party security company to audit Agile Season,
but the codebase is open source.
We believe that transparency and this document can help keep Agile Season
as secure as possible.

What happens when you authenticate your GitHub account
------------------------------------------------------

Agile Season uses the [OmniAuth GitHub] Ruby gem to
authenticate your GitHub account using [GitHub's OAuth2 flow][gh-oauth]
and provide Agile Season with a GitHub token.

[OmniAuth GitHub]: https://github.com/intridea/omniauth-github
[gh-oauth]: https://developer.github.com/v3/oauth/

Using OAuth2 means we do not access your GitHub password
and that you can revoke our access at any time.

Your GitHub token is needed in order to fetch issue content, comments and repo
information. This token doesn't stored in our
Postgres database.

To browse the portions of the codebase related to authentication,
try `grep`ing for the following terms:

```bash
grep -R omniauth app
grep -R github_token app
```

What happens when Agile Season refreshes your GitHub repositories
----------------------------------------------------------

We pass your GitHub token to our [Ruby on Rails] app
(the app whose source code you are reading right now),
which runs on [Linode]. Linode is a "Cloud Hosting".

As part of this process,
we temporarily store your [encrypted] GitHub token in the Redis database
when enqueueing a Sidekiq workers.

```bash
grep -R encrypted_github_token app
```

[Ruby on Rails]: http://rubyonrails.org
[Linode]: https://www.linode.com
[Sidekiq]: https://github.com/mperham/sidekiq
[encrypted]: ../lib/encryptor.rb

Employee access
---------------

All agileseason employees have access to change Agile Season's source code
(the repo you're reading right now, which is open source)
and to push it to GitHub.

All agileseason employees have access to
Agile Season's staging and production Linode applications and databases.
They can deploy new code, or read and write to the databases.

What you can do to make your Agile Season use safer
--------------------------------------------

Use environment variables in your code
to [separate code from configuration][12factor].

[12factor]: http://12factor.net/config

Third-party auditing
--------------------

We can't afford to hire a third party security company to audit Agile Season,
but the codebase is open source.
We believe that transparency and this document can help keep Agile Season
as secure as possible.
