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

  This construction relies crucially on the cancellation property. Later, we
  will learn about its general form, called the INT-construction.

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
<span class="IdrisType">Symmetric</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisType">List</span>&nbsp;<span class="IdrisBound">a</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisType">Overlap</span>&nbsp;<span class="IdrisKeyword">where</span><br />
&nbsp;&nbsp;<span class="IdrisFunction">symmetric</span>&nbsp;<span class="IdrisBound">xs\_overlaps\_ys</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisData">Overlapping</span><br />
&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisKeyword">{</span>&nbsp;<span class="IdrisBound">common</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisBound">xs\_overlaps\_ys</span><span class="IdrisFunction">.common</span><br />
&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisKeyword">,</span>&nbsp;<span class="IdrisBound">lhsPos</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisBound">xs\_overlaps\_ys</span><span class="IdrisFunction">.rhsPos</span><br />
&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisKeyword">,</span>&nbsp;<span class="IdrisBound">rhsPos</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisBound">xs\_overlaps\_ys</span><span class="IdrisFunction">.lhsPos</span><br />
&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisKeyword">}</span><br />
</code>
However, `Overlap` is neither reflexive nor transitive:

* The empty list doesn't overlap with itself:
<code class="IdrisCode">
<span class="IdrisFunction">Ex3</span>&nbsp;<span class="IdrisKeyword">:</span>&nbsp;<span class="IdrisFunction">Not</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisType">Overlap</span>&nbsp;<span class="IdrisData">[]</span>&nbsp;<span class="IdrisData">[]</span><span class="IdrisKeyword">)</span><br />
<span class="IdrisFunction">Ex3</span>&nbsp;<span class="IdrisBound">nil\_overlaps\_nil</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisKeyword">case</span>&nbsp;<span class="IdrisBound">nil\_overlaps\_nil</span><span class="IdrisFunction">.lhsPos</span>&nbsp;<span class="IdrisKeyword">of</span><br />
&nbsp;&nbsp;<span class="IdrisKeyword">\_</span>&nbsp;<span class="IdrisKeyword">impossible</span><br />
</code>

* Two lists may overlap with a middle list, but on different elements. For example:
<code class="IdrisCode">
<span class="IdrisFunction">Ex4</span>&nbsp;<span class="IdrisKeyword">:</span>&nbsp;<span class="IdrisKeyword">(</span>&nbsp;<span class="IdrisType">Overlap</span>&nbsp;<span class="IdrisData">[1]</span>&nbsp;<span class="IdrisData">[1,2]</span><br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisType">,</span>&nbsp;<span class="IdrisType">Overlap</span>&nbsp;<span class="IdrisData">[1,2]</span>&nbsp;<span class="IdrisData">[2]</span><br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisType">,</span>&nbsp;<span class="IdrisFunction">Not</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisType">Overlap</span>&nbsp;<span class="IdrisData">[1]</span>&nbsp;<span class="IdrisData">[2]</span><span class="IdrisKeyword">))</span><br />
<span class="IdrisFunction">Ex4</span>&nbsp;<span class="IdrisKeyword">=</span><br />
&nbsp;&nbsp;<span class="IdrisKeyword">(</span>&nbsp;<span class="IdrisData">Overlapping</span>&nbsp;<span class="IdrisData">1</span>&nbsp;<span class="IdrisData">Here</span>&nbsp;<span class="IdrisData">Here</span><br />
&nbsp;&nbsp;<span class="IdrisData">,</span>&nbsp;<span class="IdrisData">Overlapping</span>&nbsp;<span class="IdrisData">2</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisData">There</span>&nbsp;<span class="IdrisData">Here</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisData">Here</span><br />
&nbsp;&nbsp;<span class="IdrisData">,</span>&nbsp;<span class="IdrisKeyword">\</span>&nbsp;<span class="IdrisBound">one\_overlaps\_two</span>&nbsp;<span class="IdrisKeyword">=&gt;</span>&nbsp;<span class="IdrisKeyword">case</span>&nbsp;<span class="IdrisBound">one\_overlaps\_two</span><span class="IdrisFunction">.lhsPos</span>&nbsp;<span class="IdrisKeyword">of</span><br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisData">There</span>&nbsp;<span class="IdrisKeyword">\_</span>&nbsp;<span class="IdrisKeyword">impossible</span><br />
&nbsp;&nbsp;<span class="IdrisKeyword">)</span><br />
</code>
The outer lists agree on `1` and `2`, respectively, but they can't overlap on
on the first element of either, which exhausts all possibilities of overlap.



<code class="IdrisCode">
<span class="IdrisBound">-</span>-<span class="IdrisFunction">&nbsp;TO</span>D<span class="IdrisBound">O</span>:<span class="IdrisKeyword">&nbsp;</span>c<span class="IdrisKeyword">l</span><span class="IdrisBound">e</span><span class="IdrisFunction">an&nbsp;t</span>h<span class="IdrisFunction">i</span>s<span class="IdrisBound">&nbsp;</span><span class="IdrisFunction">up</span><br />
(.+.)&nbsp;:&nbsp;(x,&nbsp;y&nbsp;:&nbsp;INT)&nbsp;-&gt;&nbsp;INT<br />
<span class="IdrisFunction">x&nbsp;.+.</span>&nbsp;<span class="IdrisKeyword">y</span>&nbsp;<span class="IdrisKeyword">=</span><span class="IdrisBound">&nbsp;</span><span class="IdrisKeyword">(</span>x<span class="IdrisBound">.</span>p<span class="IdrisKeyword">o</span>s<span class="IdrisType">&nbsp;+&nbsp;</span><span class="IdrisKeyword">y</span>.<span class="IdrisKeyword">po</span>s<span class="IdrisType">)&nbsp;.</span>-.&nbsp;(x.neg&nbsp;+&nbsp;y.neg)<br />
<br />
(.\*.)&nbsp;:&nbsp;(x,&nbsp;y&nbsp;:&nbsp;INT)&nbsp;-&gt;&nbsp;INT<br />
<span class="IdrisFunction">x</span><span class="IdrisKeyword">&nbsp;</span>.<span class="IdrisFunction">\*</span>.<span class="IdrisKeyword">&nbsp;</span>y<span class="IdrisType">&nbsp;=&nbsp;</span>(x.pos&nbsp;\*&nbsp;y.pos&nbsp;+&nbsp;x.neg&nbsp;\*&nbsp;y.neg)&nbsp;.-.&nbsp;(x.pos&nbsp;\*&nbsp;y.neg&nbsp;+&nbsp;x.neg&nbsp;\*&nbsp;y.pos)<br />
<br />
<span class="IdrisFunction">O</span>,<span class="IdrisKeyword">&nbsp;</span>I<span class="IdrisData">&nbsp;</span>:<span class="IdrisData">&nbsp;IN</span>T<br />
<span class="IdrisFunction">O&nbsp;=&nbsp;0&nbsp;.-.&nbsp;0</span><br />
<span class="IdrisFunction">I&nbsp;=&nbsp;1&nbsp;.-.&nbsp;0</span><br />
plusIntZeroLftNeutral&nbsp;:&nbsp;(x&nbsp;:&nbsp;INT)&nbsp;-&gt;&nbsp;O&nbsp;.+.&nbsp;x&nbsp;`SameDiff`&nbsp;x<br />
<span class="IdrisFunction">plusIntZeroLftNeutral</span>&nbsp;<span class="IdrisKeyword">x</span>&nbsp;<span class="IdrisKeyword">=</span><span class="IdrisBound">&nbsp;</span>C<span class="IdrisKeyword">h</span>e<span class="IdrisType">ck&nbsp;</span><span class="IdrisKeyword">R</span>e<span class="IdrisKeyword">fl</span><br />
<br />
plusIntZeroRgtNeutral&nbsp;:&nbsp;(x&nbsp;:&nbsp;INT)&nbsp;-&gt;&nbsp;<span class="IdrisKeyword">x</span><span class="IdrisBound">&nbsp;</span>.<span class="IdrisKeyword">+</span>.<span class="IdrisFunction">&nbsp;O&nbsp;`SameDiff</span><span class="IdrisKeyword">`</span>&nbsp;x<br />
plusIntZeroRgtNeutral&nbsp;x&nbsp;=&nbsp;Check&nbsp;(solv<span class="IdrisKeyword">e</span><span class="IdrisFunction">&nbsp;</span>2<span class="IdrisData">&nbsp;</span>M<span class="IdrisFunction">ono</span>i<span class="IdrisFunction">d.</span><span class="IdrisKeyword">C</span>o<span class="IdrisFunction">mmu</span>t<span class="IdrisFunction">a</span>t<span class="IdrisData">i</span>ve.Free.Free<br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisFunction">&nbsp;&nbsp;&nbsp;</span>&nbsp;<span class="IdrisFunction">{</span>a<span class="IdrisData">&nbsp;</span>=<span class="IdrisFunction">&nbsp;Na</span>t<span class="IdrisKeyword">.</span><span class="IdrisFunction">A</span>d<span class="IdrisData">d</span>i<span class="IdrisFunction">tiv</span>e<span class="IdrisFunction">}&nbsp;</span><span class="IdrisKeyword">$</span><br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;(X&nbsp;0&nbsp;.+.&nbsp;O1)&nbsp;.+.&nbsp;X&nbsp;1<br />
<span class="IdrisFunction">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>&nbsp;<span class="IdrisKeyword">&nbsp;</span>&nbsp;<span class="IdrisKeyword">&nbsp;</span><span class="IdrisBound">&nbsp;</span><span class="IdrisKeyword">&nbsp;</span><span class="IdrisBound">&nbsp;</span><span class="IdrisKeyword">&nbsp;</span><span class="IdrisBound">&nbsp;</span>&nbsp;<span class="IdrisKeyword">&nbsp;</span>&nbsp;<span class="IdrisType">&nbsp;&nbsp;&nbsp;</span><span class="IdrisKeyword">=</span>-<span class="IdrisKeyword">=&nbsp;</span>X<span class="IdrisBound">&nbsp;</span>0<span class="IdrisFunction">&nbsp;.+</span>.<span class="IdrisKeyword">&nbsp;</span><span class="IdrisBound">(</span>X<span class="IdrisFunction">&nbsp;1&nbsp;</span>.<span class="IdrisBound">+</span><span class="IdrisKeyword">.</span>&nbsp;<span class="IdrisType">O1))</span><br />
<br />
plusInrAssociative&nbsp;:&nbsp;(x,y,z&nbsp;:&nbsp;INT)&nbsp;-&gt;<span class="IdrisKeyword">&nbsp;</span><span class="IdrisBound">x</span>&nbsp;<span class="IdrisKeyword">.</span>+<span class="IdrisFunction">.&nbsp;(y&nbsp;.+.&nbsp;z)&nbsp;</span><span class="IdrisKeyword">`</span>SameDiff`&nbsp;(x&nbsp;.+.&nbsp;y)&nbsp;.+.&nbsp;z<br />
plusInrAssociative&nbsp;x&nbsp;y&nbsp;z&nbsp;=&nbsp;Check&nbsp;$<span class="IdrisKeyword">&nbsp;</span><span class="IdrisFunction">(</span>s<span class="IdrisData">o</span>l<span class="IdrisFunction">ve&nbsp;</span>6<span class="IdrisKeyword">&nbsp;</span><span class="IdrisFunction">M</span>o<span class="IdrisData">n</span>o<span class="IdrisFunction">id.</span>C<span class="IdrisFunction">o</span>m<span class="IdrisData">m</span><span class="IdrisKeyword">ut</span>a<span class="IdrisFunction">tiv</span>e<span class="IdrisKeyword">.F</span><span class="IdrisFunction">r</span>e<span class="IdrisData">e</span>.<span class="IdrisFunction">Fre</span>e<br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisFunction">&nbsp;&nbsp;&nbsp;</span>{<span class="IdrisKeyword">a</span><span class="IdrisFunction">&nbsp;</span>=<span class="IdrisData">&nbsp;</span>N<span class="IdrisFunction">at.</span>A<span class="IdrisFunction">d</span>d<span class="IdrisData">i</span>t<span class="IdrisFunction">ive</span>}<span class="IdrisFunction">&nbsp;</span>$<br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;(X&nbsp;0&nbsp;.+.&nbsp;(X&nbsp;1&nbsp;.+.&nbsp;X&nbsp;2))&nbsp;.+.&nbsp;((X&nbsp;3&nbsp;.+.&nbsp;X&nbsp;4)&nbsp;.+.&nbsp;X&nbsp;5)<br />
<span class="IdrisKeyword">&nbsp;&nbsp;&nbsp;&nbsp;</span>&nbsp;<span class="IdrisType">&nbsp;&nbsp;&nbsp;&nbsp;</span>&nbsp;<span class="IdrisKeyword">&nbsp;</span>&nbsp;<span class="IdrisType">&nbsp;&nbsp;&nbsp;&nbsp;</span>&nbsp;<span class="IdrisKeyword">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=-=&nbsp;(X&nbsp;0&nbsp;.+.&nbsp;X&nbsp;1&nbsp;.+.&nbsp;X&nbsp;2)&nbsp;.+.&nbsp;(X&nbsp;3&nbsp;.+.&nbsp;(X&nbsp;4&nbsp;.+.&nbsp;X&nbsp;5)))<br />
<br />
da<span class="IdrisData">ta&nbsp;IN</span>T<span class="IdrisKeyword">&apos;</span>&nbsp;<span class="IdrisType">:&nbsp;T</span>y<span class="IdrisKeyword">pe</span>&nbsp;<span class="IdrisType">wher</span>e<br />
&nbsp;&nbsp;IPos&nbsp;&nbsp;:&nbsp;Nat&nbsp;-&gt;&nbsp;INT&apos;<br />
<span class="IdrisType">&nbsp;&nbsp;IN</span>e<span class="IdrisType">gS&nbsp;:</span>&nbsp;<span class="IdrisType">Nat&nbsp;-&gt;&nbsp;</span>I<span class="IdrisKeyword">NT&apos;</span><br />
<br />
Ca<span class="IdrisFunction">st&nbsp;I</span>N<span class="IdrisKeyword">T</span><span class="IdrisData">&apos;&nbsp;Int</span>e<span class="IdrisBound">g</span><span class="IdrisKeyword">e</span>r<span class="IdrisKeyword">&nbsp;</span>w<span class="IdrisFunction">h</span>e<span class="IdrisFunction">re</span><br />
&nbsp;&nbsp;cast&nbsp;(IPos&nbsp;k)&nbsp;=&nbsp;cast&nbsp;k<br />
<span class="IdrisType">&nbsp;&nbsp;ca</span>s<span class="IdrisType">t&nbsp;(I</span>N<span class="IdrisType">egS</span>&nbsp;<span class="IdrisKeyword">k)&nbsp;=&nbsp;</span>-&nbsp;cast&nbsp;(S&nbsp;k)<br />
<br />
Ca<span class="IdrisFunction">st&nbsp;I</span>N<span class="IdrisKeyword">T</span><span class="IdrisData">&apos;&nbsp;INT</span>&nbsp;<span class="IdrisBound">w</span><span class="IdrisKeyword">h</span>e<span class="IdrisKeyword">r</span>e<br />
&nbsp;&nbsp;cast&nbsp;(IPos&nbsp;k)&nbsp;=&nbsp;k&nbsp;.-.&nbsp;0<br />
<span class="IdrisFunction">&nbsp;&nbsp;cast&nbsp;(I</span>N<span class="IdrisKeyword">e</span>g<span class="IdrisType">S&nbsp;k</span>)<span class="IdrisKeyword">&nbsp;=</span>&nbsp;<span class="IdrisType">0&nbsp;.</span>-.&nbsp;(S&nbsp;k)<br />
<br />
<span class="IdrisFunction">normalise</span>&nbsp;<span class="IdrisBound">:</span><span class="IdrisKeyword">&nbsp;IN</span><span class="IdrisData">T</span>&nbsp;<span class="IdrisBound">-</span><span class="IdrisKeyword">&gt;</span>&nbsp;<span class="IdrisData">INT</span><br />
<span class="IdrisFunction">normalise</span>&nbsp;<span class="IdrisBound">i</span><span class="IdrisKeyword">@(0</span><span class="IdrisData">&nbsp;</span>.<span class="IdrisBound">-</span><span class="IdrisKeyword">.</span>&nbsp;<span class="IdrisData">neg</span>&nbsp;<span class="IdrisKeyword">&nbsp;</span><span class="IdrisData">&nbsp;</span>&nbsp;<span class="IdrisBound">&nbsp;</span><span class="IdrisKeyword">&nbsp;)</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisFunction">i</span><br />
normalise&nbsp;i@((S&nbsp;k)&nbsp;.-.&nbsp;0&nbsp;&nbsp;&nbsp;&nbsp;)&nbsp;=&nbsp;i<br />
<span class="IdrisFunction">normalise&nbsp;i@((S&nbsp;k)&nbsp;</span>.<span class="IdrisKeyword">-</span>.<span class="IdrisKeyword">&nbsp;</span><span class="IdrisBound">(</span>S<span class="IdrisKeyword">&nbsp;</span>j<span class="IdrisType">))&nbsp;</span><span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisKeyword">no</span>r<span class="IdrisType">malise</span>&nbsp;<span class="IdrisKeyword">(k</span><span class="IdrisFunction">&nbsp;.-.&nbsp;j)</span><br />
<br />
<span class="IdrisFunction">normaliseEitherZero</span>&nbsp;<span class="IdrisBound">:</span><span class="IdrisKeyword">&nbsp;(x</span><span class="IdrisData">&nbsp;</span>:<span class="IdrisBound">&nbsp;</span><span class="IdrisKeyword">I</span>N<span class="IdrisData">T)&nbsp;</span>-<span class="IdrisData">&gt;</span>&nbsp;Eit<span class="IdrisKeyword">h</span>e<span class="IdrisKeyword">r</span>&nbsp;<span class="IdrisData">((nor</span>m<span class="IdrisData">alis</span>e&nbsp;x).pos&nbsp;=&nbsp;Z)&nbsp;((normalise&nbsp;x).neg&nbsp;=&nbsp;Z)<br />
<span class="IdrisFunction">normaliseEitherZero</span>&nbsp;<span class="IdrisBound">i</span><span class="IdrisKeyword">@(0</span><span class="IdrisData">&nbsp;</span>.<span class="IdrisBound">-</span><span class="IdrisKeyword">.</span>&nbsp;<span class="IdrisData">neg</span>&nbsp;<span class="IdrisKeyword">&nbsp;</span><span class="IdrisData">&nbsp;</span>&nbsp;<span class="IdrisBound">&nbsp;</span><span class="IdrisKeyword">&nbsp;)</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisFunction">Left&nbsp;Refl</span><br />
normaliseEitherZero&nbsp;i@((S&nbsp;k)&nbsp;.-.&nbsp;0&nbsp;&nbsp;&nbsp;&nbsp;)&nbsp;=&nbsp;Right&nbsp;Refl<br />
<span class="IdrisType">norm</span>a<span class="IdrisType">lis</span>e<span class="IdrisType">Eith</span>e<span class="IdrisKeyword">rZero</span>&nbsp;i@((S&nbsp;k)&nbsp;.-.&nbsp;(S&nbsp;j))&nbsp;=&nbsp;normaliseEitherZero&nbsp;(k&nbsp;.-.&nbsp;j)<br />
<br />
Cast<span class="IdrisKeyword">&nbsp;INT</span>&nbsp;<span class="IdrisFunction">INT&apos;&nbsp;where</span><br />
&nbsp;&nbsp;cast<span class="IdrisKeyword">&nbsp;</span><span class="IdrisData">x&nbsp;=&nbsp;</span>l<span class="IdrisBound">e</span><span class="IdrisKeyword">t</span>&nbsp;<span class="IdrisKeyword">(p</span>o<span class="IdrisKeyword">s&nbsp;.-</span>.<span class="IdrisBound">&nbsp;ne</span>g<span class="IdrisKeyword">)&nbsp;</span>=&nbsp;normalise&nbsp;x&nbsp;in<br />
&nbsp;&nbsp;&nbsp;&nbsp;case<span class="IdrisData">&nbsp;</span>n<span class="IdrisKeyword">or</span>m<span class="IdrisData">alis</span>e<span class="IdrisData">E</span>itherZero&nbsp;x&nbsp;of<br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;(L<span class="IdrisKeyword">e</span><span class="IdrisData">f</span>t<span class="IdrisBound">&nbsp;</span><span class="IdrisKeyword">y</span>)<span class="IdrisKeyword">&nbsp;=</span>&gt;<span class="IdrisData">&nbsp;case</span>&nbsp;<span class="IdrisBound">n</span>eg&nbsp;of<br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisKeyword">&nbsp;</span><span class="IdrisData">&nbsp;0&nbsp;=&gt;</span>&nbsp;<span class="IdrisBound">I</span><span class="IdrisKeyword">P</span>o<span class="IdrisKeyword">s&nbsp;</span>0<br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;(S&nbsp;k)&nbsp;=&gt;&nbsp;INegS&nbsp;k<br />
<span class="IdrisComment">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;(Right&nbsp;y)&nbsp;=&gt;&nbsp;IPo</span>s&nbsp;pos<br />
<br />
<span class="IdrisComment">--&nbsp;stuff&nbsp;you&nbsp;can&nbsp;show:</span><br />
<br />
<span class="IdrisBound">-</span>-<span class="IdrisFunction">&nbsp;x&nbsp;</span>`<span class="IdrisBound">S</span>a<span class="IdrisKeyword">m</span>e<span class="IdrisFunction">Diff</span>`<span class="IdrisKeyword">&nbsp;</span><span class="IdrisFunction">y&nbsp;-&gt;</span>&nbsp;<span class="IdrisBound">n</span>o<span class="IdrisFunction">rma</span>l<span class="IdrisFunction">ise&nbsp;</span>x<span class="IdrisBound">&nbsp;</span><span class="IdrisKeyword">=</span>&nbsp;normalise&nbsp;y<br />
<span class="IdrisBound">(</span>:<span class="IdrisFunction">\*:)</span>,<span class="IdrisBound">&nbsp;</span>(<span class="IdrisKeyword">:</span>+<span class="IdrisFunction">:)&nbsp;:</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisFunction">x,y&nbsp;</span>:<span class="IdrisBound">&nbsp;</span>I<span class="IdrisFunction">NT&apos;</span>)<span class="IdrisFunction">&nbsp;-&gt;&nbsp;</span>I<span class="IdrisBound">N</span><span class="IdrisKeyword">T</span>&apos;<br />
x&nbsp;:+:&nbsp;y&nbsp;=&nbsp;cast&nbsp;(cast&nbsp;x&nbsp;.+.&nbsp;cast&nbsp;y)<br />
x&nbsp;:\*:&nbsp;y&nbsp;=&nbsp;cast&nbsp;(cast&nbsp;x&nbsp;.\*.&nbsp;cast&nbsp;y)<br />
<br />
</code>

