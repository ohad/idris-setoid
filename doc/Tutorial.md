<style>
.IdrisData {
  color: darkred
}
.IdrisType {
  color: blue
}
.IdrisBound {
  color: black
}
.IdrisFunction {
  color: darkgreen
}
.IdrisKeyword {
  font-weight: bold;
}
.IdrisComment {
  color: #b22222
}
.IdrisNamespace {
  font-style: italic;
  color: black
}
.IdrisPostulate {
  font-weight: bold;
  color: red
}
.IdrisModule {
  font-style: italic;
  color: black
}
.IdrisCode {
  display: block;
  background-color: whitesmoke;
}
</style>

# Tutorial: Setoids

A _setoid_ is a type equipped with an equivalence relation. Setoids come up when
you need types with a better behaved equality relation, or when you want the
equality relation to carry additional information. After completing this
tutorial you will:

1. Know the user interface to the `setoid` package.
2. Know two different applications in which it can be used:
  + constructing types with an equality relation that's better behaved than
    Idris's built-in `Equal` type.

  + types with an equality relation that carries additional information

If you want to see the source-code behind this tutorial, check the
[source-code](sources/Tutorial.md) out.

## Equivalence relations

A _relation_ over a type `ty` in Idris is any two-argument type-valued function:
```
namespace Control.Relation
  Rel : Type -> Type
  Rel ty = ty -> ty -> Type
```
This definition and its associated interfaces ship with idris's standard
library. Given a relation `rel : Rel ty` and `x,y : ty`, we can form
```x `rel` y : Type```: the type of ways in which `x` and `y` can be related.

For example, two lists _overlap_ when they have a common element:
<code class="IdrisCode">
<span class="IdrisKeyword">record</span>&nbsp;<span class="IdrisType">Overlap</span>&nbsp;<span class="IdrisKeyword">{0</span>&nbsp;<span class="IdrisBound">a</span>&nbsp;<span class="IdrisKeyword">:</span>&nbsp;<span class="IdrisType">Type</span><span class="IdrisKeyword">}</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">xs</span><span class="IdrisKeyword">,</span><span class="IdrisBound">ys</span>&nbsp;<span class="IdrisKeyword">:</span>&nbsp;<span class="IdrisType">List</span>&nbsp;<span class="IdrisBound">a</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisKeyword">where</span><br />
&nbsp;&nbsp;constructor&nbsp;<span class="IdrisData">Overlapping</span><br />
&nbsp;&nbsp;<span class="IdrisFunction">common</span>&nbsp;<span class="IdrisKeyword">:</span>&nbsp;<span class="IdrisBound">a</span><br />
&nbsp;&nbsp;<span class="IdrisFunction">lhsPos</span>&nbsp;<span class="IdrisKeyword">:</span>&nbsp;<span class="IdrisBound">common</span>&nbsp;<span class="IdrisType">`Elem`</span>&nbsp;<span class="IdrisBound">xs</span><br />
&nbsp;&nbsp;<span class="IdrisFunction">rhsPos</span>&nbsp;<span class="IdrisKeyword">:</span>&nbsp;<span class="IdrisBound">common</span>&nbsp;<span class="IdrisType">`Elem`</span>&nbsp;<span class="IdrisBound">ys</span><br />
<br />
</code>
Lists can overlap in exactly one position:
<code class="IdrisCode">
<span class="IdrisFunction">Ex1</span>&nbsp;<span class="IdrisKeyword">:</span>&nbsp;<span class="IdrisType">Overlap</span>&nbsp;<span class="IdrisData">[1,2,3]</span>&nbsp;<span class="IdrisData">[6,7,2,8]</span><br />
<span class="IdrisFunction">Ex1</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisData">Overlapping</span><br />
&nbsp;&nbsp;<span class="IdrisKeyword">{</span>&nbsp;<span class="IdrisBound">common</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisData">2</span><br />
&nbsp;&nbsp;<span class="IdrisKeyword">,</span>&nbsp;<span class="IdrisBound">lhsPos</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisData">There</span>&nbsp;<span class="IdrisData">Here</span><br />
&nbsp;&nbsp;<span class="IdrisKeyword">,</span>&nbsp;<span class="IdrisBound">rhsPos</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisData">There</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisData">There</span>&nbsp;<span class="IdrisData">Here</span><span class="IdrisKeyword">)</span><br />
&nbsp;&nbsp;<span class="IdrisKeyword">}</span><br />
</code>
But they can overlap in several ways:
<code class="IdrisCode">
<span class="IdrisFunction">Ex2a</span>&nbsp;<span class="IdrisKeyword">,</span><br />
<span class="IdrisFunction">Ex2b</span>&nbsp;<span class="IdrisKeyword">,</span><br />
<span class="IdrisFunction">Ex2c</span>&nbsp;<span class="IdrisKeyword">:</span>&nbsp;<span class="IdrisType">Overlap</span>&nbsp;<span class="IdrisData">[1,2,3]</span>&nbsp;<span class="IdrisData">[2,3,2]</span><br />
<span class="IdrisFunction">Ex2a</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisData">Overlapping</span><br />
&nbsp;&nbsp;<span class="IdrisKeyword">{</span>&nbsp;<span class="IdrisBound">common</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisData">3</span><br />
&nbsp;&nbsp;<span class="IdrisKeyword">,</span>&nbsp;<span class="IdrisBound">lhsPos</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisData">There</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisData">There</span>&nbsp;<span class="IdrisData">Here</span><span class="IdrisKeyword">)</span><br />
&nbsp;&nbsp;<span class="IdrisKeyword">,</span>&nbsp;<span class="IdrisBound">rhsPos</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisData">There</span>&nbsp;<span class="IdrisData">Here</span><br />
&nbsp;&nbsp;<span class="IdrisKeyword">}</span><br />
<span class="IdrisFunction">Ex2b</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisData">Overlapping</span><br />
&nbsp;&nbsp;<span class="IdrisKeyword">{</span>&nbsp;<span class="IdrisBound">common</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisData">2</span><br />
&nbsp;&nbsp;<span class="IdrisKeyword">,</span>&nbsp;<span class="IdrisBound">lhsPos</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisData">There</span>&nbsp;<span class="IdrisData">Here</span><br />
&nbsp;&nbsp;<span class="IdrisKeyword">,</span>&nbsp;<span class="IdrisBound">rhsPos</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisData">Here</span><br />
&nbsp;&nbsp;<span class="IdrisKeyword">}</span><br />
<span class="IdrisFunction">Ex2c</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisData">Overlapping</span><br />
&nbsp;&nbsp;<span class="IdrisKeyword">{</span>&nbsp;<span class="IdrisBound">common</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisData">2</span><br />
&nbsp;&nbsp;<span class="IdrisKeyword">,</span>&nbsp;<span class="IdrisBound">lhsPos</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisData">There</span>&nbsp;<span class="IdrisData">Here</span><br />
&nbsp;&nbsp;<span class="IdrisKeyword">,</span>&nbsp;<span class="IdrisBound">rhsPos</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisData">There</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisData">There</span>&nbsp;<span class="IdrisData">Here</span><span class="IdrisKeyword">)</span><br />
&nbsp;&nbsp;<span class="IdrisKeyword">}</span><br />
</code>
We can think of a relation `rel : Rel ty` as the type of edges in a directed
graph between vertices in `ty`:

* edges have a direction: the type `rel x y` is different to `rel y x`

* multiple different edges between the same vertices `e1, e2 : rel x y`

* self-loops between the same vertex are allowed `loop : rel x x`.

An _equivalence relation_ is a relation that's:

*  _reflexive_: we guarantee a specific way in which every element is related to
  itself;

* _symmetric_: we can reverse an edge between two edges; and

* _transitive_: we can compose paths of related elements into a single edge.

<code class="IdrisCode">
<span class="IdrisKeyword">record</span>&nbsp;<span class="IdrisType">Equivalence</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">A</span>&nbsp;<span class="IdrisKeyword">:</span>&nbsp;<span class="IdrisType">Type</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisKeyword">where</span><br />
&nbsp;&nbsp;constructor&nbsp;<span class="IdrisData">MkEquivalence</span><br />
&nbsp;&nbsp;<span class="IdrisKeyword">0</span>&nbsp;<span class="IdrisFunction">relation</span><span class="IdrisKeyword">:</span>&nbsp;<span class="IdrisFunction">Rel</span>&nbsp;<span class="IdrisBound">A</span><br />
&nbsp;&nbsp;<span class="IdrisFunction">reflexive</span>&nbsp;<span class="IdrisKeyword">:</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">x</span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisKeyword">:</span>&nbsp;<span class="IdrisBound">A</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisKeyword">-&gt;</span>&nbsp;<span class="IdrisBound">relation</span>&nbsp;<span class="IdrisBound">x</span>&nbsp;<span class="IdrisBound">x</span><br />
&nbsp;&nbsp;<span class="IdrisFunction">symmetric</span>&nbsp;<span class="IdrisKeyword">:</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">x</span><span class="IdrisKeyword">,</span>&nbsp;<span class="IdrisBound">y</span>&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisKeyword">:</span>&nbsp;<span class="IdrisBound">A</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisKeyword">-&gt;</span>&nbsp;<span class="IdrisBound">relation</span>&nbsp;<span class="IdrisBound">x</span>&nbsp;<span class="IdrisBound">y</span>&nbsp;<span class="IdrisKeyword">-&gt;</span>&nbsp;<span class="IdrisBound">relation</span>&nbsp;<span class="IdrisBound">y</span>&nbsp;<span class="IdrisBound">x</span><br />
&nbsp;&nbsp;<span class="IdrisFunction">transitive</span><span class="IdrisKeyword">:</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">x</span><span class="IdrisKeyword">,</span>&nbsp;<span class="IdrisBound">y</span><span class="IdrisKeyword">,</span>&nbsp;<span class="IdrisBound">z</span>&nbsp;<span class="IdrisKeyword">:</span>&nbsp;<span class="IdrisBound">A</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisKeyword">-&gt;</span>&nbsp;<span class="IdrisBound">relation</span>&nbsp;<span class="IdrisBound">x</span>&nbsp;<span class="IdrisBound">y</span>&nbsp;<span class="IdrisKeyword">-&gt;</span>&nbsp;<span class="IdrisBound">relation</span>&nbsp;<span class="IdrisBound">y</span>&nbsp;<span class="IdrisBound">z</span><br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisKeyword">-&gt;</span>&nbsp;<span class="IdrisBound">relation</span>&nbsp;<span class="IdrisBound">x</span>&nbsp;<span class="IdrisBound">z</span><br />
</code>

We equip the built-in relation `Equal` with the structure of an equivalence
relation, using the constructor `Refl` and the stdlib functions `sym`, and
`trans`:
<code class="IdrisCode">
<span class="IdrisFunction">EqualityEquivalence</span>&nbsp;<span class="IdrisKeyword">:</span>&nbsp;<span class="IdrisType">Equivalence</span>&nbsp;<span class="IdrisBound">a</span><br />
<span class="IdrisFunction">EqualityEquivalence</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisData">MkEquivalence</span><br />
&nbsp;&nbsp;<span class="IdrisKeyword">{</span>&nbsp;<span class="IdrisBound">relation</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisFunction">(===)</span><br />
&nbsp;&nbsp;<span class="IdrisKeyword">,</span>&nbsp;<span class="IdrisBound">reflexive</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisKeyword">\</span><span class="IdrisBound">x</span>&nbsp;<span class="IdrisKeyword">=&gt;</span>&nbsp;<span class="IdrisData">Refl</span><br />
&nbsp;&nbsp;<span class="IdrisKeyword">,</span>&nbsp;<span class="IdrisBound">symmetric</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisKeyword">\</span><span class="IdrisBound">x</span><span class="IdrisKeyword">,</span><span class="IdrisBound">y</span><span class="IdrisKeyword">,</span><span class="IdrisBound">x\_eq\_y</span>&nbsp;<span class="IdrisKeyword">=&gt;</span>&nbsp;<span class="IdrisFunction">sym</span>&nbsp;<span class="IdrisBound">x\_eq\_y</span><br />
&nbsp;&nbsp;<span class="IdrisKeyword">,</span>&nbsp;<span class="IdrisBound">transitive</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisKeyword">\</span><span class="IdrisBound">x</span><span class="IdrisKeyword">,</span><span class="IdrisBound">y</span><span class="IdrisKeyword">,</span><span class="IdrisBound">z</span><span class="IdrisKeyword">,</span><span class="IdrisBound">x\_eq\_y</span><span class="IdrisKeyword">,</span><span class="IdrisBound">y\_eq\_z</span>&nbsp;<span class="IdrisKeyword">=&gt;</span>&nbsp;<span class="IdrisFunction">trans</span>&nbsp;<span class="IdrisBound">x\_eq\_y</span>&nbsp;<span class="IdrisBound">y\_eq\_z</span><br />
&nbsp;&nbsp;<span class="IdrisKeyword">}</span><br />
</code>

We'll use the following relation on pairs of natural numbers as a running
example. We can represent an integer as the difference between a pair of natural
numbers:
<code class="IdrisCode">
<span class="IdrisKeyword">infix</span>&nbsp;<span class="IdrisKeyword">8</span>&nbsp;.-.<br />
<br />
<span class="IdrisKeyword">record</span>&nbsp;<span class="IdrisType">INT</span>&nbsp;<span class="IdrisKeyword">where</span><br />
&nbsp;&nbsp;constructor&nbsp;<span class="IdrisData">(.-.)</span><br />
&nbsp;&nbsp;<span class="IdrisFunction">pos</span><span class="IdrisKeyword">,</span>&nbsp;<span class="IdrisFunction">neg</span>&nbsp;<span class="IdrisKeyword">:</span>&nbsp;<span class="IdrisType">Nat</span><br />
<br />
<span class="IdrisKeyword">record</span>&nbsp;<span class="IdrisType">SameDiff</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">x</span><span class="IdrisKeyword">,</span>&nbsp;<span class="IdrisBound">y</span>&nbsp;<span class="IdrisKeyword">:</span>&nbsp;<span class="IdrisType">INT</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisKeyword">where</span><br />
&nbsp;&nbsp;constructor&nbsp;<span class="IdrisData">Check</span><br />
&nbsp;&nbsp;<span class="IdrisFunction">same</span>&nbsp;<span class="IdrisKeyword">:</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">x</span><span class="IdrisFunction">.pos&nbsp;+&nbsp;</span><span class="IdrisBound">y</span><span class="IdrisFunction">.neg&nbsp;===&nbsp;</span><span class="IdrisBound">y</span><span class="IdrisFunction">.pos&nbsp;+&nbsp;</span><span class="IdrisBound">x</span><span class="IdrisFunction">.neg</span><span class="IdrisKeyword">)</span><br />
</code>
The `SameDiff x y` relation is equivalent to mathematical equation that states
that the difference between the positive and negative parts is identical:
$$x_{pos} - x_{neg} = y_{pos} - y_{neg}$$
But, unlike the last equation which requires us to define integers and
subtraction, its equivalent `(.same)` is expressed using only addition, and
so addition on `Nat` is enough.

The relation `SameDiff` is an equivalence relation. The proofs are
straightforward, and a good opportunity to practice Idris's equational
reasoning combinators from `Syntax.PreorderReasoning`:
<code class="IdrisCode">
<span class="IdrisFunction">SameDiffEquivalence</span>&nbsp;<span class="IdrisKeyword">:</span>&nbsp;<span class="IdrisType">Equivalence</span>&nbsp;<span class="IdrisType">INT</span><br />
<span class="IdrisFunction">SameDiffEquivalence</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisData">MkEquivalence</span><br />
&nbsp;&nbsp;<span class="IdrisKeyword">{</span>&nbsp;<span class="IdrisBound">relation</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisType">SameDiff</span><br />
&nbsp;&nbsp;<span class="IdrisKeyword">,</span>&nbsp;<span class="IdrisBound">reflexive</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisKeyword">\</span><span class="IdrisBound">x</span>&nbsp;<span class="IdrisKeyword">=&gt;</span>&nbsp;<span class="IdrisData">Check</span>&nbsp;$&nbsp;<span class="IdrisFunction">Calc</span>&nbsp;$<br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisData">|~</span>&nbsp;<span class="IdrisBound">x</span><span class="IdrisFunction">.pos</span>&nbsp;<span class="IdrisFunction">+</span>&nbsp;<span class="IdrisBound">x</span><span class="IdrisFunction">.neg</span><br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisData">~~</span>&nbsp;<span class="IdrisBound">x</span><span class="IdrisFunction">.pos</span>&nbsp;<span class="IdrisFunction">+</span>&nbsp;<span class="IdrisBound">x</span><span class="IdrisFunction">.neg</span>&nbsp;<span class="IdrisData">...</span><span class="IdrisKeyword">(</span><span class="IdrisData">Refl</span><span class="IdrisKeyword">)</span><br />
</code>
This equational proof represents the single-step equational proof:

"Calculate:

1.   $x_{pos} + x_{neg}$
2. $= x_{pos} + x_{neg}$ (by reflexivity)"

The mnemonic behind the ASCII-art is that the first step in the proof
starts with a logical-judgement symbol $\vdash$, each step continues with an
equality sign $=$, and justified by a thought bubble `(...)`.

<code class="IdrisCode">
&nbsp;&nbsp;<span class="IdrisKeyword">,</span>&nbsp;<span class="IdrisBound">symmetric</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisKeyword">\</span><span class="IdrisBound">x</span><span class="IdrisKeyword">,</span><span class="IdrisBound">y</span><span class="IdrisKeyword">,</span><span class="IdrisBound">x\_eq\_y</span>&nbsp;<span class="IdrisKeyword">=&gt;</span>&nbsp;<span class="IdrisData">Check</span>&nbsp;$&nbsp;<span class="IdrisFunction">Calc</span>&nbsp;$<br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisData">|~</span>&nbsp;<span class="IdrisBound">y</span><span class="IdrisFunction">.pos</span>&nbsp;<span class="IdrisFunction">+</span>&nbsp;<span class="IdrisBound">x</span><span class="IdrisFunction">.neg</span><br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisData">~~</span>&nbsp;<span class="IdrisBound">x</span><span class="IdrisFunction">.pos</span>&nbsp;<span class="IdrisFunction">+</span>&nbsp;<span class="IdrisBound">y</span><span class="IdrisFunction">.neg</span>&nbsp;<span class="IdrisFunction">..&lt;</span><span class="IdrisKeyword">(</span><span class="IdrisBound">x\_eq\_y</span><span class="IdrisFunction">.same</span><span class="IdrisKeyword">)</span><br />
</code>
  In this proof, we were given the proof `x_eq_y.same : x.pos + y.neg = y.pos + x.neg`
  and so we appealed to the symmetric equation. The mnemonic here is that the
  last bubble in the thought bubble `(...)` is replace with a left-pointing arrow,
  reversing the reasoning step.
<code class="IdrisCode">
&nbsp;&nbsp;<span class="IdrisKeyword">,</span>&nbsp;<span class="IdrisBound">transitive</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisKeyword">\</span><span class="IdrisBound">x</span><span class="IdrisKeyword">,</span><span class="IdrisBound">y</span><span class="IdrisKeyword">,</span><span class="IdrisBound">z</span><span class="IdrisKeyword">,</span><span class="IdrisBound">x\_eq\_y</span><span class="IdrisKeyword">,</span><span class="IdrisBound">y\_eq\_z</span>&nbsp;<span class="IdrisKeyword">=&gt;</span>&nbsp;<span class="IdrisData">Check</span>&nbsp;$&nbsp;<span class="IdrisFunction">plusRightCancel</span>&nbsp;<span class="IdrisKeyword">\_</span>&nbsp;<span class="IdrisKeyword">\_</span>&nbsp;<span class="IdrisBound">y</span><span class="IdrisFunction">.pos</span><br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;$&nbsp;<span class="IdrisFunction">Calc</span>&nbsp;$<br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisData">|~</span>&nbsp;<span class="IdrisBound">x</span><span class="IdrisFunction">.pos</span>&nbsp;<span class="IdrisFunction">+</span>&nbsp;<span class="IdrisBound">z</span><span class="IdrisFunction">.neg</span>&nbsp;<span class="IdrisFunction">+</span>&nbsp;<span class="IdrisBound">y</span><span class="IdrisFunction">.pos</span><br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisData">~~</span>&nbsp;<span class="IdrisBound">x</span><span class="IdrisFunction">.pos</span>&nbsp;<span class="IdrisFunction">+</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">y</span><span class="IdrisFunction">.pos</span>&nbsp;<span class="IdrisFunction">+</span>&nbsp;<span class="IdrisBound">z</span><span class="IdrisFunction">.neg</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisData">...</span><span class="IdrisKeyword">(</span><span class="IdrisFunction">solve</span>&nbsp;<span class="IdrisData">3</span>&nbsp;<span class="IdrisFunction">Monoid.Commutative.Free.Free</span><br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisKeyword">{</span><span class="IdrisBound">a</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisFunction">Nat.Additive</span><span class="IdrisKeyword">}</span>&nbsp;$<br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisFunction">X</span>&nbsp;<span class="IdrisData">0</span>&nbsp;<span class="IdrisFunction">.+.</span>&nbsp;<span class="IdrisFunction">X</span>&nbsp;<span class="IdrisData">1</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisFunction">.+.</span>&nbsp;<span class="IdrisFunction">X</span>&nbsp;<span class="IdrisData">2</span><br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisFunction">=-=</span>&nbsp;<span class="IdrisFunction">X</span>&nbsp;<span class="IdrisData">0</span>&nbsp;<span class="IdrisFunction">.+.</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisFunction">X</span>&nbsp;<span class="IdrisData">2</span>&nbsp;<span class="IdrisFunction">.+.</span>&nbsp;<span class="IdrisFunction">X</span>&nbsp;<span class="IdrisData">1</span><span class="IdrisKeyword">))</span><br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisData">~~</span>&nbsp;<span class="IdrisBound">x</span><span class="IdrisFunction">.pos</span>&nbsp;<span class="IdrisFunction">+</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">z</span><span class="IdrisFunction">.pos</span>&nbsp;<span class="IdrisFunction">+</span>&nbsp;<span class="IdrisBound">y</span><span class="IdrisFunction">.neg</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisData">...</span><span class="IdrisKeyword">(</span><span class="IdrisFunction">cong</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">x</span><span class="IdrisFunction">.pos</span>&nbsp;<span class="IdrisFunction">+</span><span class="IdrisKeyword">)</span>&nbsp;$&nbsp;<span class="IdrisBound">y\_eq\_z</span><span class="IdrisFunction">.same</span><span class="IdrisKeyword">)</span><br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisData">~~</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">x</span><span class="IdrisFunction">.pos</span>&nbsp;<span class="IdrisFunction">+</span>&nbsp;<span class="IdrisBound">y</span><span class="IdrisFunction">.neg</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisFunction">+</span>&nbsp;<span class="IdrisBound">z</span><span class="IdrisFunction">.pos</span>&nbsp;<span class="IdrisData">...</span><span class="IdrisKeyword">(</span><span class="IdrisFunction">solve</span>&nbsp;<span class="IdrisData">3</span>&nbsp;<span class="IdrisFunction">Monoid.Commutative.Free.Free</span><br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisKeyword">{</span><span class="IdrisBound">a</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisFunction">Nat.Additive</span><span class="IdrisKeyword">}</span>&nbsp;$<br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisFunction">X</span>&nbsp;<span class="IdrisData">0</span>&nbsp;<span class="IdrisFunction">.+.</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisFunction">X</span>&nbsp;<span class="IdrisData">1</span>&nbsp;<span class="IdrisFunction">.+.</span>&nbsp;<span class="IdrisFunction">X</span>&nbsp;<span class="IdrisData">2</span><span class="IdrisKeyword">)</span><br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisFunction">=-=</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisFunction">X</span>&nbsp;<span class="IdrisData">0</span>&nbsp;<span class="IdrisFunction">.+.</span>&nbsp;<span class="IdrisFunction">X</span>&nbsp;<span class="IdrisData">2</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisFunction">.+.</span>&nbsp;<span class="IdrisFunction">X</span>&nbsp;<span class="IdrisData">1</span><span class="IdrisKeyword">)</span><br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisData">~~</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">y</span><span class="IdrisFunction">.pos</span>&nbsp;<span class="IdrisFunction">+</span>&nbsp;<span class="IdrisBound">x</span><span class="IdrisFunction">.neg</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisFunction">+</span>&nbsp;<span class="IdrisBound">z</span><span class="IdrisFunction">.pos</span>&nbsp;<span class="IdrisData">...</span><span class="IdrisKeyword">(</span><span class="IdrisFunction">cong</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisFunction">+</span>&nbsp;<span class="IdrisBound">z</span><span class="IdrisFunction">.pos</span><span class="IdrisKeyword">)</span>&nbsp;?h2<span class="IdrisKeyword">)</span><br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisData">~~</span>&nbsp;<span class="IdrisBound">z</span><span class="IdrisFunction">.pos</span>&nbsp;<span class="IdrisFunction">+</span>&nbsp;<span class="IdrisBound">x</span><span class="IdrisFunction">.neg</span>&nbsp;<span class="IdrisFunction">+</span>&nbsp;<span class="IdrisBound">y</span><span class="IdrisFunction">.pos</span>&nbsp;&nbsp;&nbsp;<span class="IdrisData">...</span><span class="IdrisKeyword">(</span><span class="IdrisFunction">solve</span>&nbsp;<span class="IdrisData">3</span>&nbsp;<span class="IdrisFunction">Monoid.Commutative.Free.Free</span><br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisKeyword">{</span><span class="IdrisBound">a</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisFunction">Nat.Additive</span><span class="IdrisKeyword">}</span>&nbsp;$<br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisFunction">X</span>&nbsp;<span class="IdrisData">0</span>&nbsp;<span class="IdrisFunction">.+.</span>&nbsp;<span class="IdrisFunction">X</span>&nbsp;<span class="IdrisData">1</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisFunction">.+.</span>&nbsp;<span class="IdrisFunction">X</span>&nbsp;<span class="IdrisData">2</span><br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisFunction">=-=</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisFunction">X</span>&nbsp;<span class="IdrisData">2</span>&nbsp;<span class="IdrisFunction">.+.</span>&nbsp;<span class="IdrisFunction">X</span>&nbsp;<span class="IdrisData">1</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisFunction">.+.</span>&nbsp;<span class="IdrisFunction">X</span>&nbsp;<span class="IdrisData">0</span><span class="IdrisKeyword">)</span><br />
&nbsp;&nbsp;<span class="IdrisKeyword">}</span><br />
</code>
This proof is a lot more involved:

1. We appeal to the cancellation property of addition:
  $a + c = b + c \Rightarrow a = b$
2. We rearrange the term, bringing the appropriate part of `y` into contact with
  the appropriate part of `z` and `x` to transform the term.

Here we use the idris library [`Frex`](http://www.github.com/frex-project/idris-frex)
that can perform such routine
rearrangements for common algebraic structures. In this case, we use the
commutative monoid simplifier from `Frex`.
If you want to read more about `Frex`, check the
[paper](https://www.denotational.co.uk/drafts/allais-brady-corbyn-kammar-yallop-frex-dependently-typed-algebraic-simplification.pdf) out.


Idris's `Control.Relation` defines interfaces for properties like reflexivity
and transitivity. While the
setoid package doesn't use them, we'll use them in a few examples.

The `Overlap` relation from Examples 1 and 2 is symmetric:
<code class="IdrisCode">
Sy<span class="IdrisFunction">mmetric&nbsp;(</span>L<span class="IdrisBound">ist&nbsp;a)&nbsp;Overlap</span>&nbsp;<span class="IdrisKeyword">w</span>h<span class="IdrisData">ere</span><br />
&nbsp;&nbsp;sy<span class="IdrisKeyword">m</span>m<span class="IdrisBound">etric&nbsp;</span>x<span class="IdrisKeyword">s</span>\_<span class="IdrisBound">overlaps\_ys&nbsp;=&nbsp;</span><span class="IdrisFunction">Overlap</span>ping<br />
&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisKeyword">{</span>&nbsp;<span class="IdrisBound">common</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisBound">xs\_overlaps\_ys</span><span class="IdrisFunction">.common</span><br />
&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisKeyword">,</span>&nbsp;<span class="IdrisBound">lhsPos</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisBound">xs\_overlaps\_ys</span><span class="IdrisFunction">.rhsPos</span><br />
&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisKeyword">,</span>&nbsp;rhsPos&nbsp;=&nbsp;xs\_overlaps\_ys.lhsPos<br />
&nbsp;&nbsp;&nbsp;&nbsp;}<br />
</code>
However, `Overlap` is neither reflexive nor transitive:

* The empty list doesn't overlap with itself:
<code class="IdrisCode">
<span class="IdrisFunction">Ex3</span>&nbsp;<span class="IdrisBound">:&nbsp;Not&nbsp;(Overlap&nbsp;[</span>]<span class="IdrisKeyword">&nbsp;</span>[<span class="IdrisKeyword">])</span><br />
Ex<span class="IdrisKeyword">3</span>&nbsp;<span class="IdrisKeyword">nil\_overla</span>ps\_nil&nbsp;=&nbsp;case&nbsp;nil\_overlaps\_nil.lhsPos&nbsp;of<br />
&nbsp;&nbsp;\_&nbsp;impossible<br />
</code>

* Two lists may overlap with a middle list, but on different elements. For example:
<code class="IdrisCode">
Ex4&nbsp;:&nbsp;<span class="IdrisType">(</span>&nbsp;<span class="IdrisType">Overlap</span>&nbsp;<span class="IdrisData">[1]&nbsp;[</span>1<span class="IdrisData">,2]</span><br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisType">,</span>&nbsp;<span class="IdrisFunction">Ove</span>r<span class="IdrisKeyword">l</span><span class="IdrisType">ap&nbsp;[1,2</span>]<span class="IdrisData">&nbsp;[2</span>]<br />
<span class="IdrisFunction">&nbsp;&nbsp;&nbsp;</span>&nbsp;<span class="IdrisKeyword">&nbsp;</span>&nbsp;,&nbsp;Not&nbsp;(Overlap&nbsp;[1]&nbsp;[2]))<br />
Ex<span class="IdrisKeyword">4</span>&nbsp;<span class="IdrisData">=</span><br />
&nbsp;&nbsp;<span class="IdrisData">(</span>&nbsp;<span class="IdrisData">Overlapping</span>&nbsp;<span class="IdrisData">1</span>&nbsp;<span class="IdrisKeyword">H</span><span class="IdrisData">ere&nbsp;H</span>e<span class="IdrisData">re</span><br />
&nbsp;&nbsp;<span class="IdrisData">,</span>&nbsp;<span class="IdrisKeyword">O</span>v<span class="IdrisBound">erlapping&nbsp;2&nbsp;(The</span>r<span class="IdrisKeyword">e&nbsp;</span>H<span class="IdrisKeyword">ere)</span>&nbsp;<span class="IdrisBound">Here</span><br />
&nbsp;&nbsp;,&nbsp;\<span class="IdrisData">&nbsp;one\_</span>o<span class="IdrisKeyword">v</span>e<span class="IdrisKeyword">rlaps\_two&nbsp;</span>=&gt;&nbsp;case&nbsp;one\_overlaps\_two.lhsPos&nbsp;of<br />
&nbsp;&nbsp;<span class="IdrisKeyword">&nbsp;</span>&nbsp;&nbsp;There&nbsp;\_&nbsp;impossible<br />
&nbsp;&nbsp;)<br />
</code>
The outer lists agree on `1` and `2`, respectively, but they can't overlap on
on the first element of either, which exhausts all possibilities of overlap.

