Seg
===

This is a fork of Soveran's awesome string segment matching library
[Seg][1]. The purpose of this fork is to be able to
match path segments using regular expressions. It also changes the return type
of "consuming" methods to be `String?` rather than a `Bool` to be able to get
back the result of extracting without passing in a captures/inbox hash.

[1]: https://github.com/soveran/seg