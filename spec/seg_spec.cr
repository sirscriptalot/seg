require "./spec_helper"

describe "nil" do
  segment = Seg.new(nil)

  assert_equal segment.prev, ""
  assert_equal segment.curr, "/"
  assert segment.root?
end

describe "root" do
  segment = Seg.new("/")

  assert_equal segment.prev, ""
  assert_equal segment.curr, "/"
  assert segment.root?
end

describe "init" do
  segment = Seg.new("/")

  assert segment.init?
  assert segment.root?

  segment = Seg.new("/foo")

  assert segment.init?
  assert !segment.root?

  assert_equal segment.extract, "foo"

  assert !segment.init?
  assert segment.root?
end

describe "extract" do
  segment = Seg.new("/foo/bar/baz")

  assert_equal segment.extract, "foo"
  assert_equal segment.prev, "/foo"
  assert_equal segment.curr, "/bar/baz"
  assert !segment.root?

  assert_equal segment.extract, "bar"
  assert_equal segment.prev, "/foo/bar"
  assert_equal segment.curr, "/baz"
  assert !segment.root?

  assert_equal segment.extract, "baz"
  assert_equal segment.prev, "/foo/bar/baz"
  assert_equal segment.curr, ""
  assert segment.root?

  assert_equal segment.extract, nil
  assert_equal segment.prev, "/foo/bar/baz"
  assert_equal segment.curr, ""
  assert segment.root?
end

describe "retract" do
  segment = Seg.new("/foo/bar/baz")

  3.times { segment.extract }

  assert_equal segment.prev, "/foo/bar/baz"
  assert_equal segment.curr, ""

  assert_equal segment.retract, "baz"
  assert_equal segment.prev, "/foo/bar"
  assert_equal segment.curr, "/baz"
  assert !segment.root?

  assert_equal segment.retract, "bar"
  assert_equal segment.prev, "/foo"
  assert_equal segment.curr, "/bar/baz"
  assert !segment.root?

  assert_equal segment.retract, "foo"
  assert_equal segment.prev, ""
  assert_equal segment.curr, "/foo/bar/baz"
  assert !segment.root?

  assert_equal segment.retract, nil
  assert_equal segment.prev, ""
  assert_equal segment.curr, "/foo/bar/baz"
  assert !segment.root?
end

describe "consume" do
  segment = Seg.new("/foo/bar/baz")

  assert_equal segment.consume("bar"), nil
  assert_equal segment.prev, ""
  assert_equal segment.curr, "/foo/bar/baz"
  assert !segment.root?

  assert_equal segment.consume("fo"), nil
  assert_equal segment.prev, ""
  assert_equal segment.curr, "/foo/bar/baz"
  assert !segment.root?

  assert_equal segment.consume("foo"), "foo"
  assert_equal segment.prev, "/foo"
  assert_equal segment.curr, "/bar/baz"
  assert !segment.root?

  assert_equal segment.consume("foo"), nil
  assert_equal segment.prev, "/foo"
  assert_equal segment.curr, "/bar/baz"
  assert !segment.root?

  assert_equal segment.consume("bar"), "bar"
  assert_equal segment.prev, "/foo/bar"
  assert_equal segment.curr, "/baz"
  assert !segment.root?

  assert_equal segment.consume("baz"), "baz"
  assert_equal segment.prev, "/foo/bar/baz"
  assert_equal segment.curr, ""
  assert segment.root?

  assert_equal segment.consume("baz"), nil
  assert_equal segment.prev, "/foo/bar/baz"
  assert_equal segment.curr, ""
  assert segment.root?
end

describe "match" do
  segment = Seg.new("/1-foo/2-bar/3-baz")

  matcher = /\d+/
  clasher = /\b\B/

  assert_equal segment.match(clasher), nil
  assert_equal segment.prev, ""
  assert_equal segment.curr, "/1-foo/2-bar/3-baz"
  assert !segment.root?

  assert_equal segment.match(matcher), "1"
  assert_equal segment.prev, "/1-foo"
  assert_equal segment.curr, "/2-bar/3-baz"
  assert !segment.root?

  assert_equal segment.match(matcher), "2"
  assert_equal segment.prev, "/1-foo/2-bar"
  assert_equal segment.curr, "/3-baz"
  assert !segment.root?

  assert_equal segment.match(matcher), "3"
  assert_equal segment.prev, "/1-foo/2-bar/3-baz"
  assert_equal segment.curr, ""
  assert segment.root?

  assert_equal segment.match(matcher), nil
  assert_equal segment.prev, "/1-foo/2-bar/3-baz"
  assert_equal segment.curr, ""
  assert segment.root?
end

describe "restore" do
  segment = Seg.new("/foo/bar/baz")

  3.times { segment.extract }

  assert_equal segment.restore("foo"), nil
  assert_equal segment.prev, "/foo/bar/baz"
  assert_equal segment.curr, ""
  assert segment.root?

  assert_equal segment.restore("baz"), "baz"
  assert_equal segment.prev, "/foo/bar"
  assert_equal segment.curr, "/baz"
  assert !segment.root?

  assert_equal segment.restore("bar"), "bar"
  assert_equal segment.prev, "/foo"
  assert_equal segment.curr, "/bar/baz"
  assert !segment.root?

  assert_equal segment.restore("foo"), "foo"
  assert_equal segment.prev, ""
  assert_equal segment.curr, "/foo/bar/baz"
  assert !segment.root?

  assert_equal segment.restore("foo"), nil
  assert_equal segment.prev, ""
  assert_equal segment.curr, "/foo/bar/baz"
  assert !segment.root?
end

describe "capture" do
  segment = Seg.new("/foo/bar/baz")

  captures = Hash(Symbol, String).new

  assert_equal segment.capture(:c1, captures), true
  assert_equal segment.prev, "/foo"
  assert_equal segment.curr, "/bar/baz"
  assert !segment.root?

  assert_equal segment.capture(:c2, captures), true
  assert_equal segment.prev, "/foo/bar"
  assert_equal segment.curr, "/baz"
  assert !segment.root?

  assert_equal segment.capture(:c3, captures), true
  assert_equal segment.prev, "/foo/bar/baz"
  assert_equal segment.curr, ""
  assert segment.root?

  assert_equal segment.capture(:c4, captures), false
  assert_equal segment.prev, "/foo/bar/baz"
  assert_equal segment.curr, ""
  assert segment.root?

  assert_equal "foo", captures[:c1]
  assert_equal "bar", captures[:c2]
  assert_equal "baz", captures[:c3]
  assert_equal nil, captures[:c4]?
end
