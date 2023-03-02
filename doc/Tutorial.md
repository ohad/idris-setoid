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
<style>
body {
  width: 80%;
  max-width: 700px;
  margin: auto;
}
code {
  background-color: whitesmoke;
}
pre code {
  display: block;
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
<code class="IdrisCode">
<span class="IdrisFunction">Rel</span>&nbsp;<span class="IdrisKeyword">:</span>&nbsp;<span class="IdrisType">Type</span>&nbsp;<span class="IdrisKeyword">-&gt;</span>&nbsp;<span class="IdrisType">Type</span><br />
<span class="IdrisFunction">Rel</span>&nbsp;<span class="IdrisBound">ty</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisBound">ty</span>&nbsp;<span class="IdrisKeyword">-&gt;</span>&nbsp;<span class="IdrisBound">ty</span>&nbsp;<span class="IdrisKeyword">-&gt;</span>&nbsp;<span class="IdrisType">Type</span><br />
</code>

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
<span class="IdrisFunction">EqualEquivalence</span>&nbsp;<span class="IdrisKeyword">:</span>&nbsp;<span class="IdrisType">Equivalence</span>&nbsp;<span class="IdrisBound">a</span><br />
<span class="IdrisFunction">EqualEquivalence</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisData">MkEquivalence</span><br />
&nbsp;&nbsp;<span class="IdrisKeyword">{</span>&nbsp;<span class="IdrisBound">relation</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisFunction">(===)</span><br />
&nbsp;&nbsp;<span class="IdrisKeyword">,</span>&nbsp;<span class="IdrisBound">reflexive</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisKeyword">\\</span><span class="IdrisBound">x</span>&nbsp;<span class="IdrisKeyword">=&gt;</span>&nbsp;<span class="IdrisData">Refl</span><br />
&nbsp;&nbsp;<span class="IdrisKeyword">,</span>&nbsp;<span class="IdrisBound">symmetric</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisKeyword">\\</span><span class="IdrisBound">x</span><span class="IdrisKeyword">,</span><span class="IdrisBound">y</span><span class="IdrisKeyword">,</span><span class="IdrisBound">x\_eq\_y</span>&nbsp;<span class="IdrisKeyword">=&gt;</span>&nbsp;<span class="IdrisFunction">sym</span>&nbsp;<span class="IdrisBound">x\_eq\_y</span><br />
&nbsp;&nbsp;<span class="IdrisKeyword">,</span>&nbsp;<span class="IdrisBound">transitive</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisKeyword">\\</span><span class="IdrisBound">x</span><span class="IdrisKeyword">,</span><span class="IdrisBound">y</span><span class="IdrisKeyword">,</span><span class="IdrisBound">z</span><span class="IdrisKeyword">,</span><span class="IdrisBound">x\_eq\_y</span><span class="IdrisKeyword">,</span><span class="IdrisBound">y\_eq\_z</span>&nbsp;<span class="IdrisKeyword">=&gt;</span>&nbsp;<span class="IdrisFunction">trans</span>&nbsp;<span class="IdrisBound">x\_eq\_y</span>&nbsp;<span class="IdrisBound">y\_eq\_z</span><br />
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
&nbsp;&nbsp;<span class="IdrisKeyword">,</span>&nbsp;<span class="IdrisBound">reflexive</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisKeyword">\\</span><span class="IdrisBound">x</span>&nbsp;<span class="IdrisKeyword">=&gt;</span>&nbsp;<span class="IdrisData">Check</span>&nbsp;&#36;&nbsp;<span class="IdrisFunction">Calc</span>&nbsp;&#36;<br />
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
Lets continue to construct the equivalence relation over `SameDiff`:
<code class="IdrisCode">
&nbsp;&nbsp;<span class="IdrisKeyword">,</span>&nbsp;<span class="IdrisBound">symmetric</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisKeyword">\\</span><span class="IdrisBound">x</span><span class="IdrisKeyword">,</span><span class="IdrisBound">y</span><span class="IdrisKeyword">,</span><span class="IdrisBound">x\_eq\_y</span>&nbsp;<span class="IdrisKeyword">=&gt;</span>&nbsp;<span class="IdrisData">Check</span>&nbsp;&#36;&nbsp;<span class="IdrisFunction">Calc</span>&nbsp;&#36;<br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisData">|~</span>&nbsp;<span class="IdrisBound">y</span><span class="IdrisFunction">.pos</span>&nbsp;<span class="IdrisFunction">+</span>&nbsp;<span class="IdrisBound">x</span><span class="IdrisFunction">.neg</span><br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisData">~~</span>&nbsp;<span class="IdrisBound">x</span><span class="IdrisFunction">.pos</span>&nbsp;<span class="IdrisFunction">+</span>&nbsp;<span class="IdrisBound">y</span><span class="IdrisFunction">.neg</span>&nbsp;<span class="IdrisFunction">..&lt;</span><span class="IdrisKeyword">(</span><span class="IdrisBound">x\_eq\_y</span><span class="IdrisFunction">.same</span><span class="IdrisKeyword">)</span><br />
</code>
  We take the proof `x_eq_y.same : x.pos + y.neg = y.pos + x.neg` and
  appeal to the symmetric equation.  In the justification of the final
  step, we replace the last dot `(...)` with a left-pointing arrow `(..<)`,
  a mnemonic for reversing the reasoning step.
<code class="IdrisCode">
&nbsp;&nbsp;<span class="IdrisKeyword">,</span>&nbsp;<span class="IdrisBound">transitive</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisKeyword">\\</span><span class="IdrisBound">x</span><span class="IdrisKeyword">,</span><span class="IdrisBound">y</span><span class="IdrisKeyword">,</span><span class="IdrisBound">z</span><span class="IdrisKeyword">,</span><span class="IdrisBound">x\_eq\_y</span><span class="IdrisKeyword">,</span><span class="IdrisBound">y\_eq\_z</span>&nbsp;<span class="IdrisKeyword">=&gt;</span>&nbsp;<span class="IdrisData">Check</span>&nbsp;&#36;&nbsp;<span class="IdrisFunction">plusRightCancel</span>&nbsp;<span class="IdrisKeyword">\_</span>&nbsp;<span class="IdrisKeyword">\_</span>&nbsp;<span class="IdrisBound">y</span><span class="IdrisFunction">.pos</span><br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&#36;&nbsp;<span class="IdrisFunction">Calc</span>&nbsp;&#36;<br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisData">|~</span>&nbsp;<span class="IdrisBound">x</span><span class="IdrisFunction">.pos</span>&nbsp;<span class="IdrisFunction">+</span>&nbsp;<span class="IdrisBound">z</span><span class="IdrisFunction">.neg</span>&nbsp;<span class="IdrisFunction">+</span>&nbsp;<span class="IdrisBound">y</span><span class="IdrisFunction">.pos</span><br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisData">~~</span>&nbsp;<span class="IdrisBound">x</span><span class="IdrisFunction">.pos</span>&nbsp;<span class="IdrisFunction">+</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">y</span><span class="IdrisFunction">.pos</span>&nbsp;<span class="IdrisFunction">+</span>&nbsp;<span class="IdrisBound">z</span><span class="IdrisFunction">.neg</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisData">...</span><span class="IdrisKeyword">(</span><span class="IdrisFunction">solve</span>&nbsp;<span class="IdrisData">3</span>&nbsp;<span class="IdrisFunction">Monoid.Commutative.Free.Free</span><br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisKeyword">{</span><span class="IdrisBound">a</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisFunction">Nat.Additive</span><span class="IdrisKeyword">}</span>&nbsp;&#36;<br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisFunction">X</span>&nbsp;<span class="IdrisData">0</span>&nbsp;<span class="IdrisFunction">.+.</span>&nbsp;<span class="IdrisFunction">X</span>&nbsp;<span class="IdrisData">1</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisFunction">.+.</span>&nbsp;<span class="IdrisFunction">X</span>&nbsp;<span class="IdrisData">2</span><br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisFunction">=-=</span>&nbsp;<span class="IdrisFunction">X</span>&nbsp;<span class="IdrisData">0</span>&nbsp;<span class="IdrisFunction">.+.</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisFunction">X</span>&nbsp;<span class="IdrisData">2</span>&nbsp;<span class="IdrisFunction">.+.</span>&nbsp;<span class="IdrisFunction">X</span>&nbsp;<span class="IdrisData">1</span><span class="IdrisKeyword">))</span><br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisData">~~</span>&nbsp;<span class="IdrisBound">x</span><span class="IdrisFunction">.pos</span>&nbsp;<span class="IdrisFunction">+</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">z</span><span class="IdrisFunction">.pos</span>&nbsp;<span class="IdrisFunction">+</span>&nbsp;<span class="IdrisBound">y</span><span class="IdrisFunction">.neg</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisData">...</span><span class="IdrisKeyword">(</span><span class="IdrisFunction">cong</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">x</span><span class="IdrisFunction">.pos</span>&nbsp;<span class="IdrisFunction">+</span><span class="IdrisKeyword">)</span>&nbsp;&#36;&nbsp;<span class="IdrisBound">y\_eq\_z</span><span class="IdrisFunction">.same</span><span class="IdrisKeyword">)</span><br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisData">~~</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">x</span><span class="IdrisFunction">.pos</span>&nbsp;<span class="IdrisFunction">+</span>&nbsp;<span class="IdrisBound">y</span><span class="IdrisFunction">.neg</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisFunction">+</span>&nbsp;<span class="IdrisBound">z</span><span class="IdrisFunction">.pos</span>&nbsp;<span class="IdrisData">...</span><span class="IdrisKeyword">(</span>?h02<span class="IdrisComment">{-solve&nbsp;3&nbsp;Monoid.Commutative.Free.Free</span><br />
<span class="IdrisComment">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{a&nbsp;=&nbsp;Nat.Additive}&nbsp;&#36;</span><br />
<span class="IdrisComment">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;X&nbsp;0&nbsp;.+.&nbsp;(X&nbsp;1&nbsp;.+.&nbsp;X&nbsp;2)</span><br />
<span class="IdrisComment">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=-=&nbsp;(X&nbsp;0&nbsp;.+.&nbsp;X&nbsp;2)&nbsp;.+.&nbsp;X&nbsp;1-}</span><span class="IdrisKeyword">)</span><br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisData">~~</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">y</span><span class="IdrisFunction">.pos</span>&nbsp;<span class="IdrisFunction">+</span>&nbsp;<span class="IdrisBound">x</span><span class="IdrisFunction">.neg</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisFunction">+</span>&nbsp;<span class="IdrisBound">z</span><span class="IdrisFunction">.pos</span>&nbsp;<span class="IdrisData">...</span><span class="IdrisKeyword">(</span><span class="IdrisFunction">cong</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisFunction">+</span>&nbsp;<span class="IdrisBound">z</span><span class="IdrisFunction">.pos</span><span class="IdrisKeyword">)</span>&nbsp;?h002<span class="IdrisKeyword">)</span><br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisData">~~</span>&nbsp;<span class="IdrisBound">z</span><span class="IdrisFunction">.pos</span>&nbsp;<span class="IdrisFunction">+</span>&nbsp;<span class="IdrisBound">x</span><span class="IdrisFunction">.neg</span>&nbsp;<span class="IdrisFunction">+</span>&nbsp;<span class="IdrisBound">y</span><span class="IdrisFunction">.pos</span>&nbsp;&nbsp;&nbsp;<span class="IdrisData">...</span><span class="IdrisKeyword">(</span>?h01&nbsp;<span class="IdrisComment">{-}solve&nbsp;3&nbsp;Monoid.Commutative.Free.Free</span><br />
<span class="IdrisComment">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{a&nbsp;=&nbsp;Nat.Additive}&nbsp;&#36;</span><br />
<span class="IdrisComment">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;(X&nbsp;0&nbsp;.+.&nbsp;X&nbsp;1)&nbsp;.+.&nbsp;X&nbsp;2</span><br />
<span class="IdrisComment">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=-=&nbsp;(X&nbsp;2&nbsp;.+.&nbsp;X&nbsp;1)&nbsp;.+.&nbsp;X&nbsp;0-}</span><span class="IdrisKeyword">)</span><br />
&nbsp;&nbsp;<span class="IdrisKeyword">}</span><br />
</code>
This proof is more involved:

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
&nbsp;&nbsp;<span class="IdrisData">,</span>&nbsp;<span class="IdrisKeyword">\\</span>&nbsp;<span class="IdrisBound">one\_overlaps\_two</span>&nbsp;<span class="IdrisKeyword">=&gt;</span>&nbsp;<span class="IdrisKeyword">case</span>&nbsp;<span class="IdrisBound">one\_overlaps\_two</span><span class="IdrisFunction">.lhsPos</span>&nbsp;<span class="IdrisKeyword">of</span><br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisData">There</span>&nbsp;<span class="IdrisKeyword">\_</span>&nbsp;<span class="IdrisKeyword">impossible</span><br />
&nbsp;&nbsp;<span class="IdrisKeyword">)</span><br />
</code>
The outer lists agree on `1` and `2`, respectively, but they can't overlap on
on the first element of either, which exhausts all possibilities of overlap.

## Inductive `INTEGER`s

We'll show how to use setoids to verify the properties of the integers.
Currently in Idris, the `Integer` type is primitive, and while expressions
without any variables such as `2 + (3*5)` reduce to a single value during
type-checking, expressions with variables such as `5 + (3 * x)` reduce to their
primitives, which we cannot prove anything about:
```
prim__add_Integer 5 (prim__mul_Integer 3 x)
```

A natural alternative is to implement an `INTEGER` type inductively:
<code class="IdrisCode">
<span class="IdrisKeyword">data</span>&nbsp;<span class="IdrisType">INTEGER</span><br />
&nbsp;&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisData">ANat</span>&nbsp;<span class="IdrisType">Nat</span><br />
&nbsp;&nbsp;<span class="IdrisKeyword">|</span>&nbsp;<span class="IdrisData">NegS</span>&nbsp;<span class="IdrisType">Nat</span><br />
<br />
</code>
The constructor `ANat : Nat -> INTEGER` embeds the natural numbers as
the non-negative integers. The constructor `NegS : Nat -> INTEGER` embeds
them as negative, with `NegS n` representing the integer `-(1 + n)`.
We can now implement the basic `Num`eric interface:
<code class="IdrisCode">
<span class="IdrisFunction">fromInteger&apos;</span>&nbsp;<span class="IdrisKeyword">:</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">x</span>&nbsp;<span class="IdrisKeyword">:</span>&nbsp;<span class="IdrisType">Integer</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisKeyword">-&gt;</span>&nbsp;<span class="IdrisType">INTEGER</span><br />
<span class="IdrisFunction">fromInteger&apos;</span>&nbsp;<span class="IdrisBound">x</span>&nbsp;<span class="IdrisKeyword">=</span><br />
&nbsp;&nbsp;<span class="IdrisKeyword">if</span>&nbsp;<span class="IdrisBound">x</span>&nbsp;<span class="IdrisFunction">&lt;</span>&nbsp;<span class="IdrisData">0</span><br />
&nbsp;&nbsp;<span class="IdrisKeyword">then</span>&nbsp;<span class="IdrisData">NegS</span>&nbsp;&#36;&nbsp;<span class="IdrisFunction">cast</span>&nbsp;<span class="IdrisKeyword">(</span>-<span class="IdrisData">1</span>&nbsp;<span class="IdrisFunction">-</span>&nbsp;<span class="IdrisBound">x</span><span class="IdrisKeyword">)</span><br />
&nbsp;&nbsp;<span class="IdrisKeyword">else</span>&nbsp;<span class="IdrisData">ANat</span>&nbsp;&#36;&nbsp;<span class="IdrisFunction">cast</span>&nbsp;<span class="IdrisBound">x</span><br />
<br />
<span class="IdrisFunction">ANat\_Plus\_NegS</span>&nbsp;<span class="IdrisKeyword">:</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">k</span><span class="IdrisKeyword">,</span><span class="IdrisBound">j</span>&nbsp;<span class="IdrisKeyword">:</span>&nbsp;<span class="IdrisType">Nat</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisKeyword">-&gt;</span>&nbsp;<span class="IdrisType">INTEGER</span><br />
<span class="IdrisFunction">ANat\_Plus\_NegS</span>&nbsp;<span class="IdrisData">0</span>&nbsp;<span class="IdrisBound">j</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisData">NegS</span>&nbsp;<span class="IdrisBound">j</span><br />
<span class="IdrisFunction">ANat\_Plus\_NegS</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisData">S</span>&nbsp;<span class="IdrisBound">k</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisData">0</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisData">ANat</span>&nbsp;<span class="IdrisBound">k</span><br />
<span class="IdrisFunction">ANat\_Plus\_NegS</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisData">S</span>&nbsp;<span class="IdrisBound">k</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisData">S</span>&nbsp;<span class="IdrisBound">j</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisFunction">ANat\_Plus\_NegS</span>&nbsp;<span class="IdrisBound">k</span>&nbsp;<span class="IdrisBound">j</span><br />
<br />
<span class="IdrisFunction">Plus</span><span class="IdrisKeyword">,</span><span class="IdrisFunction">Mult</span>&nbsp;<span class="IdrisKeyword">:</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">x</span><span class="IdrisKeyword">,</span><span class="IdrisBound">y</span>&nbsp;<span class="IdrisKeyword">:</span>&nbsp;<span class="IdrisType">INTEGER</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisKeyword">-&gt;</span>&nbsp;<span class="IdrisType">INTEGER</span><br />
<span class="IdrisKeyword">(</span><span class="IdrisData">ANat</span>&nbsp;<span class="IdrisBound">k</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisFunction">`Plus`</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisData">ANat</span>&nbsp;<span class="IdrisBound">j</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisData">ANat</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">k</span>&nbsp;<span class="IdrisFunction">+</span>&nbsp;<span class="IdrisBound">j</span><span class="IdrisKeyword">)</span><br />
<span class="IdrisKeyword">(</span><span class="IdrisData">NegS</span>&nbsp;<span class="IdrisBound">k</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisFunction">`Plus`</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisData">NegS</span>&nbsp;<span class="IdrisBound">j</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisData">NegS</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisData">1</span>&nbsp;<span class="IdrisFunction">+</span>&nbsp;<span class="IdrisBound">k</span>&nbsp;<span class="IdrisFunction">+</span>&nbsp;<span class="IdrisBound">j</span><span class="IdrisKeyword">)</span><br />
<span class="IdrisKeyword">(</span><span class="IdrisData">ANat</span>&nbsp;<span class="IdrisBound">k</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisFunction">`Plus`</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisData">NegS</span>&nbsp;<span class="IdrisBound">j</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisFunction">ANat\_Plus\_NegS</span>&nbsp;<span class="IdrisBound">k</span>&nbsp;<span class="IdrisBound">j</span><br />
<span class="IdrisKeyword">(</span><span class="IdrisData">NegS</span>&nbsp;<span class="IdrisBound">j</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisFunction">`Plus`</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisData">ANat</span>&nbsp;<span class="IdrisBound">k</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisFunction">ANat\_Plus\_NegS</span>&nbsp;<span class="IdrisBound">k</span>&nbsp;<span class="IdrisBound">j</span><br />
<br />
<span class="IdrisFunction">NatMult</span>&nbsp;<span class="IdrisKeyword">:</span>&nbsp;<span class="IdrisType">Nat</span>&nbsp;<span class="IdrisKeyword">-&gt;</span>&nbsp;<span class="IdrisType">INTEGER</span>&nbsp;<span class="IdrisKeyword">-&gt;</span>&nbsp;<span class="IdrisType">INTEGER</span><br />
<span class="IdrisFunction">NatMult</span>&nbsp;<span class="IdrisData">0</span>&nbsp;<span class="IdrisBound">x</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisData">ANat</span>&nbsp;<span class="IdrisData">0</span><br />
<span class="IdrisFunction">NatMult</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisData">S</span>&nbsp;<span class="IdrisBound">k</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisBound">x</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisBound">x</span>&nbsp;<span class="IdrisFunction">`Plus`</span>&nbsp;<span class="IdrisFunction">NatMult</span>&nbsp;<span class="IdrisBound">k</span>&nbsp;<span class="IdrisBound">x</span><br />
<br />
<span class="IdrisFunction">Neg</span>&nbsp;<span class="IdrisKeyword">:</span>&nbsp;<span class="IdrisType">INTEGER</span>&nbsp;<span class="IdrisKeyword">-&gt;</span>&nbsp;<span class="IdrisType">INTEGER</span><br />
<span class="IdrisFunction">Neg</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisData">ANat</span>&nbsp;<span class="IdrisData">0</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisData">ANat</span>&nbsp;<span class="IdrisData">0</span><br />
<span class="IdrisFunction">Neg</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisData">ANat</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisData">S</span>&nbsp;<span class="IdrisBound">k</span><span class="IdrisKeyword">))</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisData">NegS</span>&nbsp;<span class="IdrisBound">k</span><br />
<span class="IdrisFunction">Neg</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisData">NegS</span>&nbsp;<span class="IdrisBound">k</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisData">ANat</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisData">S</span>&nbsp;<span class="IdrisBound">k</span><span class="IdrisKeyword">)</span><br />
<br />
<span class="IdrisKeyword">(</span><span class="IdrisData">ANat</span>&nbsp;<span class="IdrisBound">k</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisFunction">`Mult`</span>&nbsp;<span class="IdrisBound">y</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisFunction">NatMult</span>&nbsp;<span class="IdrisBound">k</span>&nbsp;<span class="IdrisBound">y</span><br />
<span class="IdrisKeyword">(</span><span class="IdrisData">NegS</span>&nbsp;<span class="IdrisBound">k</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisFunction">`Mult`</span>&nbsp;<span class="IdrisBound">y</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisFunction">Neg</span>&nbsp;&#36;&nbsp;<span class="IdrisFunction">NatMult</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisData">S</span>&nbsp;<span class="IdrisBound">k</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisBound">y</span><br />
<br />
<span class="IdrisType">Num</span>&nbsp;<span class="IdrisType">INTEGER</span>&nbsp;<span class="IdrisKeyword">where</span><br />
&nbsp;&nbsp;<span class="IdrisFunction">fromInteger</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisFunction">fromInteger&apos;</span><br />
&nbsp;&nbsp;<span class="IdrisFunction">(+)</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisFunction">Plus</span><br />
&nbsp;&nbsp;<span class="IdrisFunction">(\*)</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisFunction">Mult</span><br />
</code>
If it's not already clear from these definitions, reasoning about `INTEGER`s
is going to involve a _lot_ of case splitting. We'll use an appropriate setoid
to simplify these combinatorics.


## Setoids

A _setoid_ is a type equipped with an equivalence relation:
<code class="IdrisCode">
<span class="IdrisKeyword">record</span>&nbsp;<span class="IdrisType">Setoid</span>&nbsp;<span class="IdrisKeyword">where</span><br />
&nbsp;&nbsp;constructor&nbsp;<span class="IdrisData">MkSetoid</span><br />
&nbsp;&nbsp;<span class="IdrisKeyword">0</span>&nbsp;<span class="IdrisFunction">U</span>&nbsp;<span class="IdrisKeyword">:</span>&nbsp;<span class="IdrisType">Type</span><br />
&nbsp;&nbsp;<span class="IdrisFunction">equivalence</span>&nbsp;<span class="IdrisKeyword">:</span>&nbsp;<span class="IdrisType">Equivalence</span>&nbsp;<span class="IdrisBound">U</span><br />
</code>

For example, represent the integers using this setoid:
<code class="IdrisCode">
<span class="IdrisFunction">INTSetoid</span>&nbsp;<span class="IdrisKeyword">:</span>&nbsp;<span class="IdrisType">Setoid</span><br />
<span class="IdrisFunction">INTSetoid</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisData">MkSetoid</span>&nbsp;<span class="IdrisType">INT</span>&nbsp;<span class="IdrisFunction">SameDiffEquivalence</span><br />
</code>

We can turn any type into a setoid using the equality relation:

<code class="IdrisCode">
<span class="IdrisType">Cast</span>&nbsp;<span class="IdrisType">Type</span>&nbsp;<span class="IdrisType">Setoid</span>&nbsp;<span class="IdrisKeyword">where</span><br />
&nbsp;&nbsp;<span class="IdrisFunction">cast</span>&nbsp;<span class="IdrisBound">x</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisData">MkSetoid</span>&nbsp;<span class="IdrisBound">x</span>&nbsp;<span class="IdrisFunction">EqualEquivalence</span><br />
<br />
<span class="IdrisFunction">INTEGERSetoid</span>&nbsp;<span class="IdrisKeyword">:</span>&nbsp;<span class="IdrisType">Setoid</span><br />
<span class="IdrisFunction">INTEGERSetoid</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisFunction">cast</span>&nbsp;<span class="IdrisType">INTEGER</span><br />
</code>
A key difference between the setoids `INTEGERSetoid` and `INTSetoid`:

* In `INTEGERSetoid`, every equivalence class has a unique representative,
by definition:
<code class="IdrisCode">
<span class="IdrisFunction">uniqueRep</span>&nbsp;<span class="IdrisKeyword">:</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">x</span><span class="IdrisKeyword">,</span><span class="IdrisBound">y</span>&nbsp;<span class="IdrisKeyword">:</span>&nbsp;<span class="IdrisType">INTEGER</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisKeyword">-&gt;</span>&nbsp;<span class="IdrisFunction">INTEGERSetoid</span>&nbsp;<span class="IdrisFunction">.equivalence.relation</span>&nbsp;<span class="IdrisBound">x</span>&nbsp;<span class="IdrisBound">y</span>&nbsp;<span class="IdrisKeyword">-&gt;</span>&nbsp;<span class="IdrisBound">x</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisBound">y</span><br />
<span class="IdrisFunction">uniqueRep</span>&nbsp;<span class="IdrisKeyword">\_</span>&nbsp;<span class="IdrisKeyword">\_</span>&nbsp;<span class="IdrisBound">prf</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisBound">prf</span><br />
</code>

* In `INTSetoid`, we have many equivalent representatives:
<code class="IdrisCode">
<span class="IdrisFunction">Ex2</span>&nbsp;<span class="IdrisKeyword">:</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">x</span>&nbsp;<span class="IdrisKeyword">:</span>&nbsp;<span class="IdrisType">Nat</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisKeyword">-&gt;</span>&nbsp;<span class="IdrisFunction">INTSetoid</span>&nbsp;<span class="IdrisFunction">.equivalence.relation</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisData">0</span>&nbsp;<span class="IdrisData">.-.</span>&nbsp;<span class="IdrisData">0</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">x</span>&nbsp;<span class="IdrisData">.-.</span>&nbsp;<span class="IdrisBound">x</span><span class="IdrisKeyword">)</span><br />
<span class="IdrisFunction">Ex2</span>&nbsp;<span class="IdrisData">0</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisData">Check</span>&nbsp;<span class="IdrisData">Refl</span><br />
<span class="IdrisFunction">Ex2</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisData">S</span>&nbsp;<span class="IdrisBound">k</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisData">Check</span>&nbsp;&#36;&nbsp;<span class="IdrisFunction">Calc</span>&nbsp;&#36;<br />
&nbsp;&nbsp;<span class="IdrisData">|~</span>&nbsp;<span class="IdrisData">0</span>&nbsp;<span class="IdrisFunction">+</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisData">S</span>&nbsp;<span class="IdrisBound">k</span><span class="IdrisKeyword">)</span><br />
&nbsp;&nbsp;<span class="IdrisData">~~</span>&nbsp;<span class="IdrisData">S</span>&nbsp;<span class="IdrisBound">k</span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisData">...</span><span class="IdrisKeyword">(</span><span class="IdrisData">Refl</span><span class="IdrisKeyword">)</span><br />
&nbsp;&nbsp;<span class="IdrisData">~~</span>&nbsp;<span class="IdrisData">S</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">k</span>&nbsp;<span class="IdrisFunction">+</span>&nbsp;<span class="IdrisData">0</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisFunction">..&lt;</span><span class="IdrisKeyword">(</span><span class="IdrisFunction">cong</span>&nbsp;<span class="IdrisData">S</span>&nbsp;&#36;&nbsp;<span class="IdrisFunction">plusZeroRightNeutral</span>&nbsp;<span class="IdrisKeyword">\_)</span><br />
&nbsp;&nbsp;<span class="IdrisData">~~</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisData">S</span>&nbsp;<span class="IdrisBound">k</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisFunction">+</span>&nbsp;<span class="IdrisData">0</span>&nbsp;<span class="IdrisData">...</span><span class="IdrisKeyword">(</span><span class="IdrisData">Refl</span><span class="IdrisKeyword">)</span><br />
</code>

## Homomorphisms

We can convert between the two integer representations:
<code class="IdrisCode">
<span class="IdrisFunction">toINT</span>&nbsp;<span class="IdrisKeyword">:</span>&nbsp;<span class="IdrisType">INTEGER</span>&nbsp;<span class="IdrisKeyword">-&gt;</span>&nbsp;<span class="IdrisType">INT</span><br />
<span class="IdrisFunction">toINT</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisData">ANat</span>&nbsp;<span class="IdrisBound">k</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisBound">k</span>&nbsp;<span class="IdrisData">.-.</span>&nbsp;<span class="IdrisData">0</span><br />
<span class="IdrisFunction">toINT</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisData">NegS</span>&nbsp;<span class="IdrisBound">k</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisData">0</span>&nbsp;<span class="IdrisData">.-.</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisData">S</span>&nbsp;<span class="IdrisBound">k</span><span class="IdrisKeyword">)</span><br />
<br />
<span class="IdrisFunction">fromINT</span>&nbsp;<span class="IdrisKeyword">:</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">pos</span><span class="IdrisKeyword">,</span>&nbsp;<span class="IdrisBound">neg</span><span class="IdrisKeyword">:</span>&nbsp;<span class="IdrisType">Nat</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisKeyword">-&gt;</span>&nbsp;<span class="IdrisType">INTEGER</span><br />
<span class="IdrisFunction">fromINT</span>&nbsp;<span class="IdrisBound">pos</span>&nbsp;<span class="IdrisData">0</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisData">ANat</span>&nbsp;<span class="IdrisBound">pos</span><br />
<span class="IdrisFunction">fromINT</span>&nbsp;<span class="IdrisData">0</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisData">S</span>&nbsp;<span class="IdrisBound">k</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisData">NegS</span>&nbsp;<span class="IdrisBound">k</span><br />
<span class="IdrisFunction">fromINT</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisData">S</span>&nbsp;<span class="IdrisBound">pos</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisData">S</span>&nbsp;<span class="IdrisBound">neg</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisFunction">fromINT</span>&nbsp;<span class="IdrisBound">pos</span>&nbsp;<span class="IdrisBound">neg</span><br />
<br />
<span class="IdrisType">Cast</span>&nbsp;<span class="IdrisType">INTEGER</span>&nbsp;<span class="IdrisType">INT</span>&nbsp;<span class="IdrisKeyword">where</span><br />
&nbsp;&nbsp;<span class="IdrisFunction">cast</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisFunction">toINT</span><br />
<br />
<span class="IdrisType">Cast</span>&nbsp;<span class="IdrisType">INT</span>&nbsp;<span class="IdrisType">INTEGER</span>&nbsp;<span class="IdrisKeyword">where</span><br />
&nbsp;&nbsp;<span class="IdrisFunction">cast</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">pos</span>&nbsp;<span class="IdrisData">.-.</span>&nbsp;<span class="IdrisBound">neg</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisFunction">fromINT</span>&nbsp;<span class="IdrisBound">pos</span>&nbsp;<span class="IdrisBound">neg</span><br />
</code>
These two functions _preserve_ the equivalence relations of
the corresponding setoids, a property that makes them setoid _homomorphisms_:
<code class="IdrisCode">
<span class="IdrisKeyword">0</span><br />
<span class="IdrisFunction">SetoidHomomorphism</span>&nbsp;<span class="IdrisKeyword">:</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">a</span><span class="IdrisKeyword">,</span><span class="IdrisBound">b</span>&nbsp;<span class="IdrisKeyword">:</span>&nbsp;<span class="IdrisType">Setoid</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisKeyword">-&gt;</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">f</span>&nbsp;<span class="IdrisKeyword">:</span>&nbsp;<span class="IdrisFunction">U</span>&nbsp;<span class="IdrisBound">a</span>&nbsp;<span class="IdrisKeyword">-&gt;</span>&nbsp;<span class="IdrisFunction">U</span>&nbsp;<span class="IdrisBound">b</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisKeyword">-&gt;</span>&nbsp;<span class="IdrisType">Type</span><br />
<span class="IdrisFunction">SetoidHomomorphism</span>&nbsp;<span class="IdrisBound">a</span>&nbsp;<span class="IdrisBound">b</span>&nbsp;<span class="IdrisBound">f</span><br />
&nbsp;&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">x</span><span class="IdrisKeyword">,</span><span class="IdrisBound">y</span>&nbsp;<span class="IdrisKeyword">:</span>&nbsp;<span class="IdrisFunction">U</span>&nbsp;<span class="IdrisBound">a</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisKeyword">-&gt;</span>&nbsp;<span class="IdrisBound">a</span><span class="IdrisFunction">.equivalence.relation</span>&nbsp;<span class="IdrisBound">x</span>&nbsp;<span class="IdrisBound">y</span><br />
&nbsp;&nbsp;<span class="IdrisKeyword">-&gt;</span>&nbsp;<span class="IdrisBound">b</span><span class="IdrisFunction">.equivalence.relation</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">f</span>&nbsp;<span class="IdrisBound">x</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">f</span>&nbsp;<span class="IdrisBound">y</span><span class="IdrisKeyword">)</span><br />
</code>

<code class="IdrisCode">
<span class="IdrisFunction">toINTHomo</span>&nbsp;<span class="IdrisKeyword">:</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisFunction">INTEGERSetoid</span>&nbsp;<span class="IdrisFunction">`SetoidHomomorphism`</span>&nbsp;<span class="IdrisFunction">INTSetoid</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisFunction">cast</span><br />
<span class="IdrisFunction">fromINTHomo</span>&nbsp;<span class="IdrisKeyword">:</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisFunction">INTSetoid</span>&nbsp;<span class="IdrisFunction">`SetoidHomomorphism`</span>&nbsp;<span class="IdrisFunction">INTEGERSetoid</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisFunction">cast</span><br />
</code>

In one direction, the proof is in fact a special case of a general principle:
<code class="IdrisCode">
<span class="IdrisFunction">(.IsMate)</span>&nbsp;<span class="IdrisKeyword">:</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">b</span>&nbsp;<span class="IdrisKeyword">:</span>&nbsp;<span class="IdrisType">Setoid</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisKeyword">-&gt;</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">f</span>&nbsp;<span class="IdrisKeyword">:</span>&nbsp;<span class="IdrisBound">x</span>&nbsp;<span class="IdrisKeyword">-&gt;</span>&nbsp;<span class="IdrisFunction">U</span>&nbsp;<span class="IdrisBound">b</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisKeyword">-&gt;</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisFunction">cast</span>&nbsp;<span class="IdrisBound">x</span>&nbsp;<span class="IdrisFunction">`SetoidHomomorphism`</span>&nbsp;<span class="IdrisBound">b</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisBound">f</span><br />
<span class="IdrisBound">b</span><span class="IdrisFunction">.IsMate</span>&nbsp;<span class="IdrisBound">f</span>&nbsp;<span class="IdrisBound">i</span>&nbsp;<span class="IdrisBound">i</span>&nbsp;<span class="IdrisData">Refl</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisBound">b</span><span class="IdrisFunction">.equivalence.reflexive</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">f</span>&nbsp;<span class="IdrisBound">i</span><span class="IdrisKeyword">)</span><br />
<br />
<span class="IdrisFunction">toINTHomo</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisFunction">INTSetoid</span>&nbsp;<span class="IdrisFunction">.IsMate</span>&nbsp;<span class="IdrisFunction">cast</span><br />
</code>
In the other direction, we'll some lemmata:
<code class="IdrisCode">
<span class="IdrisFunction">lemma1</span>&nbsp;<span class="IdrisKeyword">:</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">pos</span><span class="IdrisKeyword">,</span><span class="IdrisBound">neg</span><span class="IdrisKeyword">,</span><span class="IdrisBound">k</span>&nbsp;<span class="IdrisKeyword">:</span>&nbsp;<span class="IdrisType">Nat</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisKeyword">-&gt;</span>&nbsp;<span class="IdrisFunction">INTSetoid</span>&nbsp;<span class="IdrisFunction">.equivalence.relation</span><br />
&nbsp;&nbsp;<span class="IdrisKeyword">((</span><span class="IdrisBound">k</span>&nbsp;<span class="IdrisFunction">+</span>&nbsp;<span class="IdrisBound">pos</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisData">.-.</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">k</span>&nbsp;<span class="IdrisFunction">+</span>&nbsp;<span class="IdrisBound">neg</span><span class="IdrisKeyword">))</span><br />
&nbsp;&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">pos</span>&nbsp;<span class="IdrisData">.-.</span>&nbsp;<span class="IdrisBound">neg</span><span class="IdrisKeyword">)</span><br />
<span class="IdrisFunction">lemma1</span>&nbsp;<span class="IdrisBound">pos</span>&nbsp;<span class="IdrisBound">neg</span>&nbsp;<span class="IdrisBound">k</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisData">Check</span>&nbsp;&#36;&nbsp;<span class="IdrisFunction">solve</span>&nbsp;<span class="IdrisData">3</span>&nbsp;<span class="IdrisFunction">Monoid.Commutative.Free.Free</span><br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisKeyword">{</span><span class="IdrisBound">a</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisFunction">Nat.Additive</span><span class="IdrisKeyword">}</span>&nbsp;&#36;<br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisFunction">X</span>&nbsp;<span class="IdrisData">0</span>&nbsp;<span class="IdrisFunction">.+.</span>&nbsp;<span class="IdrisFunction">X</span>&nbsp;<span class="IdrisData">1</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisFunction">.+.</span>&nbsp;<span class="IdrisFunction">X</span>&nbsp;<span class="IdrisData">2</span><br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisFunction">=-=</span>&nbsp;<span class="IdrisFunction">X</span>&nbsp;<span class="IdrisData">1</span>&nbsp;<span class="IdrisFunction">.+.</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisFunction">X</span>&nbsp;<span class="IdrisData">0</span>&nbsp;<span class="IdrisFunction">.+.</span>&nbsp;<span class="IdrisFunction">X</span>&nbsp;<span class="IdrisData">2</span><span class="IdrisKeyword">)</span><br />
<br />
<span class="IdrisFunction">lemma2</span>&nbsp;<span class="IdrisKeyword">:</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">pos</span><span class="IdrisKeyword">,</span><span class="IdrisBound">neg</span><span class="IdrisKeyword">,</span><span class="IdrisBound">k</span>&nbsp;<span class="IdrisKeyword">:</span>&nbsp;<span class="IdrisType">Nat</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisKeyword">-&gt;</span>&nbsp;<span class="IdrisFunction">INTEGERSetoid</span>&nbsp;<span class="IdrisFunction">.equivalence.relation</span><br />
&nbsp;&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisFunction">cast</span>&nbsp;&#36;&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">k</span>&nbsp;<span class="IdrisFunction">+</span>&nbsp;<span class="IdrisBound">pos</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisData">.-.</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">k</span>&nbsp;<span class="IdrisFunction">+</span>&nbsp;<span class="IdrisBound">neg</span><span class="IdrisKeyword">))</span><br />
&nbsp;&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisFunction">cast</span>&nbsp;&#36;&nbsp;<span class="IdrisBound">pos</span>&nbsp;<span class="IdrisData">.-.</span>&nbsp;<span class="IdrisBound">neg</span><span class="IdrisKeyword">)</span><br />
<br />
<span class="IdrisFunction">lemma2aux</span>&nbsp;<span class="IdrisKeyword">:</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">pos</span><span class="IdrisKeyword">,</span><span class="IdrisBound">neg</span><span class="IdrisKeyword">,</span><span class="IdrisBound">k</span>&nbsp;<span class="IdrisKeyword">:</span>&nbsp;<span class="IdrisType">Nat</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisKeyword">-&gt;</span>&nbsp;<span class="IdrisFunction">INTEGERSetoid</span>&nbsp;<span class="IdrisFunction">.equivalence.relation</span><br />
&nbsp;&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisFunction">fromINT</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">k</span>&nbsp;<span class="IdrisFunction">+</span>&nbsp;<span class="IdrisBound">pos</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">k</span>&nbsp;<span class="IdrisFunction">+</span>&nbsp;<span class="IdrisBound">neg</span><span class="IdrisKeyword">))</span><br />
&nbsp;&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisFunction">fromINT</span>&nbsp;<span class="IdrisBound">pos</span>&nbsp;<span class="IdrisBound">neg</span><span class="IdrisKeyword">)</span><br />
<span class="IdrisFunction">lemma2aux</span>&nbsp;<span class="IdrisBound">pos</span>&nbsp;<span class="IdrisBound">neg</span>&nbsp;<span class="IdrisData">0</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisData">Refl</span><br />
<span class="IdrisFunction">lemma2aux</span>&nbsp;<span class="IdrisBound">pos</span>&nbsp;<span class="IdrisBound">neg</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisData">S</span>&nbsp;<span class="IdrisBound">k</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisFunction">lemma2aux</span>&nbsp;<span class="IdrisBound">pos</span>&nbsp;<span class="IdrisBound">neg</span>&nbsp;<span class="IdrisBound">k</span><br />
<br />
<span class="IdrisFunction">lemma2</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisFunction">lemma2aux</span><br />
<span class="IdrisFunction">lemma2&apos;</span>&nbsp;<span class="IdrisKeyword">:</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">pos</span><span class="IdrisKeyword">,</span><span class="IdrisBound">neg</span><span class="IdrisKeyword">,</span><span class="IdrisBound">k</span>&nbsp;<span class="IdrisKeyword">:</span>&nbsp;<span class="IdrisType">Nat</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisKeyword">-&gt;</span>&nbsp;<span class="IdrisFunction">INTEGERSetoid</span>&nbsp;<span class="IdrisFunction">.equivalence.relation</span><br />
&nbsp;&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisFunction">cast</span>&nbsp;&#36;&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">pos</span>&nbsp;<span class="IdrisFunction">+</span>&nbsp;<span class="IdrisBound">k</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisData">.-.</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">neg</span>&nbsp;<span class="IdrisFunction">+</span>&nbsp;<span class="IdrisBound">k</span><span class="IdrisKeyword">))</span><br />
&nbsp;&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisFunction">cast</span>&nbsp;&#36;&nbsp;<span class="IdrisBound">pos</span>&nbsp;<span class="IdrisData">.-.</span>&nbsp;<span class="IdrisBound">neg</span><span class="IdrisKeyword">)</span><br />
<span class="IdrisFunction">lemma2&apos;</span>&nbsp;<span class="IdrisBound">pos</span>&nbsp;<span class="IdrisBound">neg</span>&nbsp;<span class="IdrisBound">k</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisFunction">Calc</span>&nbsp;&#36;<br />
&nbsp;&nbsp;<span class="IdrisData">|~</span>&nbsp;<span class="IdrisFunction">cast</span>&nbsp;<span class="IdrisKeyword">((</span><span class="IdrisBound">pos</span>&nbsp;<span class="IdrisFunction">+</span>&nbsp;<span class="IdrisBound">k</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisData">.-.</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">neg</span>&nbsp;<span class="IdrisFunction">+</span>&nbsp;<span class="IdrisBound">k</span><span class="IdrisKeyword">))</span><br />
&nbsp;&nbsp;<span class="IdrisData">~~</span>&nbsp;<span class="IdrisFunction">cast</span>&nbsp;<span class="IdrisKeyword">((</span><span class="IdrisBound">k</span>&nbsp;<span class="IdrisFunction">+</span>&nbsp;<span class="IdrisBound">pos</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisData">.-.</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">k</span>&nbsp;<span class="IdrisFunction">+</span>&nbsp;<span class="IdrisBound">neg</span><span class="IdrisKeyword">))</span><br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisData">...</span><span class="IdrisKeyword">(</span><span class="IdrisFunction">cong2</span>&nbsp;<span class="IdrisKeyword">(\\</span><span class="IdrisBound">x</span><span class="IdrisKeyword">,</span><span class="IdrisBound">y</span>&nbsp;<span class="IdrisKeyword">=&gt;</span>&nbsp;<span class="IdrisFunction">cast</span>&nbsp;&#36;&nbsp;<span class="IdrisBound">x</span>&nbsp;<span class="IdrisData">.-.</span>&nbsp;<span class="IdrisBound">y</span><span class="IdrisKeyword">)</span><br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisFunction">plusCommutative</span>&nbsp;<span class="IdrisKeyword">\_</span>&nbsp;<span class="IdrisKeyword">\_)</span><br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisFunction">plusCommutative</span>&nbsp;<span class="IdrisKeyword">\_</span>&nbsp;<span class="IdrisKeyword">\_))</span><br />
&nbsp;&nbsp;<span class="IdrisData">~~</span>&nbsp;<span class="IdrisFunction">cast</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">pos</span>&nbsp;<span class="IdrisData">.-.</span>&nbsp;<span class="IdrisBound">neg</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisData">...</span><span class="IdrisKeyword">(</span><span class="IdrisFunction">lemma2</span>&nbsp;<span class="IdrisBound">pos</span>&nbsp;<span class="IdrisBound">neg</span>&nbsp;<span class="IdrisBound">k</span><span class="IdrisKeyword">)</span><br />
</code>

<code class="IdrisCode">
<span class="IdrisFunction">fromINTHomo</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">p1</span>&nbsp;<span class="IdrisData">.-.</span>&nbsp;<span class="IdrisBound">n1</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">p2</span>&nbsp;<span class="IdrisData">.-.</span>&nbsp;<span class="IdrisBound">n2</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisBound">x\_samediff\_y</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisFunction">Calc</span>&nbsp;&#36;<br />
&nbsp;&nbsp;<span class="IdrisData">|~</span>&nbsp;<span class="IdrisFunction">cast</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">p1</span>&nbsp;<span class="IdrisData">.-.</span>&nbsp;<span class="IdrisBound">n1</span><span class="IdrisKeyword">)</span><br />
&nbsp;&nbsp;<span class="IdrisData">~~</span>&nbsp;<span class="IdrisFunction">cast</span>&nbsp;<span class="IdrisKeyword">((</span><span class="IdrisBound">p1</span>&nbsp;<span class="IdrisFunction">+</span>&nbsp;<span class="IdrisBound">n2</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisData">.-.</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">n1</span>&nbsp;<span class="IdrisFunction">+</span>&nbsp;<span class="IdrisBound">n2</span><span class="IdrisKeyword">))</span>&nbsp;&nbsp;<span class="IdrisFunction">..&lt;</span><span class="IdrisKeyword">(</span><span class="IdrisFunction">Tutorial.lemma2&apos;</span>&nbsp;<span class="IdrisKeyword">\_</span>&nbsp;<span class="IdrisKeyword">\_</span>&nbsp;<span class="IdrisKeyword">\_)</span><br />
&nbsp;&nbsp;<span class="IdrisData">~~</span>&nbsp;<span class="IdrisFunction">cast</span>&nbsp;<span class="IdrisKeyword">{</span><span class="IdrisBound">to</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisType">INTEGER</span><span class="IdrisKeyword">}</span><br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisKeyword">((</span><span class="IdrisBound">p2</span>&nbsp;<span class="IdrisFunction">+</span>&nbsp;<span class="IdrisBound">n1</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisData">.-.</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">n2</span>&nbsp;<span class="IdrisFunction">+</span>&nbsp;<span class="IdrisBound">n1</span><span class="IdrisKeyword">))</span>&nbsp;&nbsp;<span class="IdrisData">...</span><span class="IdrisKeyword">(</span><span class="IdrisFunction">cong2</span>&nbsp;<span class="IdrisKeyword">(\\</span><span class="IdrisBound">x</span><span class="IdrisKeyword">,</span><span class="IdrisBound">y</span>&nbsp;<span class="IdrisKeyword">=&gt;</span>&nbsp;<span class="IdrisFunction">cast</span>&nbsp;&#36;&nbsp;<span class="IdrisBound">x</span>&nbsp;<span class="IdrisData">.-.</span>&nbsp;<span class="IdrisBound">y</span><span class="IdrisKeyword">)</span><br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">x\_samediff\_y</span><span class="IdrisFunction">.same</span><span class="IdrisKeyword">)</span><br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisFunction">plusCommutative</span>&nbsp;<span class="IdrisKeyword">\_</span>&nbsp;<span class="IdrisKeyword">\_))</span><br />
&nbsp;&nbsp;<span class="IdrisData">~~</span>&nbsp;<span class="IdrisFunction">cast</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">p2</span>&nbsp;<span class="IdrisData">.-.</span>&nbsp;<span class="IdrisBound">n2</span><span class="IdrisKeyword">)</span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisData">...</span><span class="IdrisKeyword">(</span><span class="IdrisFunction">Tutorial.lemma2&apos;</span>&nbsp;<span class="IdrisKeyword">\_</span>&nbsp;<span class="IdrisKeyword">\_</span>&nbsp;<span class="IdrisKeyword">\_)</span><br />
</code>

We define the type of setoid homomorphisms:
<code class="IdrisCode">
<span class="IdrisKeyword">record</span>&nbsp;<span class="IdrisType">(~&gt;)</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">A</span><span class="IdrisKeyword">,</span><span class="IdrisBound">B</span>&nbsp;<span class="IdrisKeyword">:</span>&nbsp;<span class="IdrisType">Setoid</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisKeyword">where</span><br />
&nbsp;&nbsp;constructor&nbsp;<span class="IdrisData">MkSetoidHomomorphism</span><br />
&nbsp;&nbsp;<span class="IdrisFunction">H</span>&nbsp;<span class="IdrisKeyword">:</span>&nbsp;<span class="IdrisFunction">U</span>&nbsp;<span class="IdrisBound">A</span>&nbsp;<span class="IdrisKeyword">-&gt;</span>&nbsp;<span class="IdrisFunction">U</span>&nbsp;<span class="IdrisBound">B</span><br />
&nbsp;&nbsp;<span class="IdrisFunction">homomorphic</span>&nbsp;<span class="IdrisKeyword">:</span>&nbsp;<span class="IdrisFunction">SetoidHomomorphism</span>&nbsp;<span class="IdrisBound">A</span>&nbsp;<span class="IdrisBound">B</span>&nbsp;<span class="IdrisBound">H</span><br />
</code>

And use it to package the two functions as homomorphisms:
<code class="IdrisCode">
<span class="IdrisFunction">ToINT</span>&nbsp;<span class="IdrisKeyword">:</span>&nbsp;<span class="IdrisFunction">INTEGERSetoid</span>&nbsp;<span class="IdrisType">~&gt;</span>&nbsp;<span class="IdrisFunction">INTSetoid</span><br />
<span class="IdrisFunction">ToINT</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisData">MkSetoidHomomorphism</span>&nbsp;<span class="IdrisKeyword">\_</span>&nbsp;<span class="IdrisFunction">toINTHomo</span><br />
<span class="IdrisFunction">FromINT</span>&nbsp;<span class="IdrisKeyword">:</span>&nbsp;<span class="IdrisFunction">INTSetoid</span>&nbsp;<span class="IdrisType">~&gt;</span>&nbsp;<span class="IdrisFunction">INTEGERSetoid</span><br />
<span class="IdrisFunction">FromINT</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisData">MkSetoidHomomorphism</span>&nbsp;<span class="IdrisKeyword">\_</span>&nbsp;<span class="IdrisFunction">fromINTHomo</span><br />
</code>

The setoid methodology is affectionately called _setoid hell_, because as we
need to propagate the setoid equivalence through complex structures,
we accrue bigger and bigger proof obligations. This situation can be
ameliorated by packaging the homomorphism condition in compositional building
blocks.

For example, the identity setoid homomorphism
and the composition of setoid homomorphisms:
<code class="IdrisCode">
<span class="IdrisFunction">id</span>&nbsp;<span class="IdrisKeyword">:</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">a</span>&nbsp;<span class="IdrisKeyword">:</span>&nbsp;<span class="IdrisType">Setoid</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisKeyword">-&gt;</span>&nbsp;<span class="IdrisBound">a</span>&nbsp;<span class="IdrisType">~&gt;</span>&nbsp;<span class="IdrisBound">a</span><br />
<span class="IdrisFunction">id</span>&nbsp;<span class="IdrisBound">a</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisData">MkSetoidHomomorphism</span>&nbsp;<span class="IdrisFunction">Prelude.id</span>&nbsp;&#36;&nbsp;<span class="IdrisKeyword">\\</span><span class="IdrisBound">x</span><span class="IdrisKeyword">,</span>&nbsp;<span class="IdrisBound">y</span><span class="IdrisKeyword">,</span>&nbsp;<span class="IdrisBound">prf</span>&nbsp;<span class="IdrisKeyword">=&gt;</span>&nbsp;<span class="IdrisBound">prf</span><br />
<br />
<span class="IdrisFunction">(.)</span>&nbsp;<span class="IdrisKeyword">:</span>&nbsp;<span class="IdrisKeyword">{</span><span class="IdrisBound">a</span><span class="IdrisKeyword">,</span><span class="IdrisBound">b</span><span class="IdrisKeyword">,</span><span class="IdrisBound">c</span>&nbsp;<span class="IdrisKeyword">:</span>&nbsp;<span class="IdrisType">Setoid</span><span class="IdrisKeyword">}</span>&nbsp;<span class="IdrisKeyword">-&gt;</span>&nbsp;<span class="IdrisBound">b</span>&nbsp;<span class="IdrisType">~&gt;</span>&nbsp;<span class="IdrisBound">c</span>&nbsp;<span class="IdrisKeyword">-&gt;</span>&nbsp;<span class="IdrisBound">a</span>&nbsp;<span class="IdrisType">~&gt;</span>&nbsp;<span class="IdrisBound">b</span>&nbsp;<span class="IdrisKeyword">-&gt;</span>&nbsp;<span class="IdrisBound">a</span>&nbsp;<span class="IdrisType">~&gt;</span>&nbsp;<span class="IdrisBound">c</span><br />
<span class="IdrisBound">g</span>&nbsp;<span class="IdrisFunction">.</span>&nbsp;<span class="IdrisBound">f</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisData">MkSetoidHomomorphism</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisFunction">H</span>&nbsp;<span class="IdrisBound">g</span>&nbsp;<span class="IdrisFunction">.</span>&nbsp;<span class="IdrisFunction">H</span>&nbsp;<span class="IdrisBound">f</span><span class="IdrisKeyword">)</span>&nbsp;&#36;&nbsp;<span class="IdrisKeyword">\\</span><span class="IdrisBound">x</span><span class="IdrisKeyword">,</span><span class="IdrisBound">y</span><span class="IdrisKeyword">,</span><span class="IdrisBound">prf</span>&nbsp;<span class="IdrisKeyword">=&gt;</span><br />
&nbsp;&nbsp;<span class="IdrisBound">g</span><span class="IdrisFunction">.homomorphic</span>&nbsp;<span class="IdrisKeyword">\_</span>&nbsp;<span class="IdrisKeyword">\_</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">f</span><span class="IdrisFunction">.homomorphic</span>&nbsp;<span class="IdrisKeyword">\_</span>&nbsp;<span class="IdrisKeyword">\_</span>&nbsp;<span class="IdrisBound">prf</span><span class="IdrisKeyword">)</span><br />
</code>

As another example, we can package the information about preservation
of setoid relations in more abstract setoids like this setoid of setoid
homomorphisms:
<code class="IdrisCode">
<span class="IdrisKeyword">0</span>&nbsp;<span class="IdrisFunction">SetoidHomoExtensionality</span>&nbsp;<span class="IdrisKeyword">:</span>&nbsp;<span class="IdrisKeyword">{</span><span class="IdrisBound">a</span><span class="IdrisKeyword">,</span><span class="IdrisBound">b</span>&nbsp;<span class="IdrisKeyword">:</span>&nbsp;<span class="IdrisType">Setoid</span><span class="IdrisKeyword">}</span>&nbsp;<span class="IdrisKeyword">-&gt;</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">f</span><span class="IdrisKeyword">,</span>&nbsp;<span class="IdrisBound">g</span>&nbsp;<span class="IdrisKeyword">:</span>&nbsp;<span class="IdrisBound">a</span>&nbsp;<span class="IdrisType">~&gt;</span>&nbsp;<span class="IdrisBound">b</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisKeyword">-&gt;</span>&nbsp;<span class="IdrisType">Type</span><br />
<span class="IdrisFunction">SetoidHomoExtensionality</span>&nbsp;<span class="IdrisBound">f</span>&nbsp;<span class="IdrisBound">g</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">x</span>&nbsp;<span class="IdrisKeyword">:</span>&nbsp;<span class="IdrisFunction">U</span>&nbsp;<span class="IdrisBound">a</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisKeyword">-&gt;</span><br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisBound">b</span><span class="IdrisFunction">.equivalence.relation</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">f</span><span class="IdrisFunction">.H</span>&nbsp;<span class="IdrisBound">x</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">g</span><span class="IdrisFunction">.H</span>&nbsp;<span class="IdrisBound">x</span><span class="IdrisKeyword">)</span><br />
<br />
<span class="IdrisFunction">(~~&gt;)</span>&nbsp;<span class="IdrisKeyword">:</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">a</span><span class="IdrisKeyword">,</span><span class="IdrisBound">b</span>&nbsp;<span class="IdrisKeyword">:</span>&nbsp;<span class="IdrisType">Setoid</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisKeyword">-&gt;</span>&nbsp;<span class="IdrisType">Setoid</span><br />
<span class="IdrisFunction">(~~&gt;)</span>&nbsp;<span class="IdrisBound">a</span>&nbsp;<span class="IdrisBound">b</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisData">MkSetoid</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">a</span>&nbsp;<span class="IdrisType">~&gt;</span>&nbsp;<span class="IdrisBound">b</span><span class="IdrisKeyword">)</span>&nbsp;&#36;<br />
&nbsp;&nbsp;<span class="IdrisData">MkEquivalence</span><br />
&nbsp;&nbsp;<span class="IdrisKeyword">{</span>&nbsp;<span class="IdrisBound">relation</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisFunction">SetoidHomoExtensionality</span><br />
&nbsp;&nbsp;<span class="IdrisKeyword">,</span>&nbsp;<span class="IdrisBound">reflexive</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisKeyword">\\</span><span class="IdrisBound">f</span><span class="IdrisKeyword">,</span><span class="IdrisBound">v</span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisKeyword">=&gt;</span><br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisBound">b</span><span class="IdrisFunction">.equivalence.reflexive</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">f</span><span class="IdrisFunction">.H</span>&nbsp;<span class="IdrisBound">v</span><span class="IdrisKeyword">)</span><br />
&nbsp;&nbsp;<span class="IdrisKeyword">,</span>&nbsp;<span class="IdrisBound">symmetric</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisKeyword">\\</span><span class="IdrisBound">f</span><span class="IdrisKeyword">,</span><span class="IdrisBound">g</span><span class="IdrisKeyword">,</span><span class="IdrisBound">prf</span><span class="IdrisKeyword">,</span><span class="IdrisBound">w</span>&nbsp;<span class="IdrisKeyword">=&gt;</span><br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisBound">b</span><span class="IdrisFunction">.equivalence.symmetric</span>&nbsp;<span class="IdrisKeyword">\_</span>&nbsp;<span class="IdrisKeyword">\_</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">prf</span>&nbsp;<span class="IdrisBound">w</span><span class="IdrisKeyword">)</span><br />
&nbsp;&nbsp;<span class="IdrisKeyword">,</span>&nbsp;<span class="IdrisBound">transitive</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisKeyword">\\</span><span class="IdrisBound">f</span><span class="IdrisKeyword">,</span><span class="IdrisBound">g</span><span class="IdrisKeyword">,</span><span class="IdrisBound">h</span><span class="IdrisKeyword">,</span><span class="IdrisBound">f\_eq\_g</span><span class="IdrisKeyword">,</span><span class="IdrisBound">g\_eq\_h</span><span class="IdrisKeyword">,</span><span class="IdrisBound">q</span>&nbsp;<span class="IdrisKeyword">=&gt;</span><br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisBound">b</span><span class="IdrisFunction">.equivalence.transitive</span>&nbsp;<span class="IdrisKeyword">\_</span>&nbsp;<span class="IdrisKeyword">\_</span>&nbsp;<span class="IdrisKeyword">\_</span><br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">f\_eq\_g</span>&nbsp;<span class="IdrisBound">q</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">g\_eq\_h</span>&nbsp;<span class="IdrisBound">q</span><span class="IdrisKeyword">)</span><br />
&nbsp;&nbsp;<span class="IdrisKeyword">}</span><br />
</code>


## Isomorphisms and Setoid Equational Reasoning

Going the round-trip `INTEGER` to `INT` and back to `INTEGER` always produces
the same result:
<code class="IdrisCode">
<span class="IdrisFunction">FromToId</span>&nbsp;<span class="IdrisKeyword">:</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">x</span>&nbsp;<span class="IdrisKeyword">:</span>&nbsp;<span class="IdrisType">INTEGER</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisKeyword">-&gt;</span><br />
&nbsp;&nbsp;<span class="IdrisFunction">INTEGERSetoid</span>&nbsp;<span class="IdrisFunction">.equivalence.relation</span><br />
&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisFunction">cast</span>&nbsp;&#36;&nbsp;<span class="IdrisFunction">cast</span>&nbsp;<span class="IdrisKeyword">{</span><span class="IdrisBound">to</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisType">INT</span><span class="IdrisKeyword">}</span>&nbsp;<span class="IdrisBound">x</span><span class="IdrisKeyword">)</span><br />
&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisBound">x</span><br />
<span class="IdrisFunction">FromToId</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisData">ANat</span>&nbsp;<span class="IdrisBound">k</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisData">Refl</span><br />
<span class="IdrisFunction">FromToId</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisData">NegS</span>&nbsp;<span class="IdrisBound">k</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisData">Refl</span><br />
</code>
Going the other round-trip, `INT` to `INTEGER` and back to `INT`, may produce
different results, for example `toINT (fromINT 8 3)` is `5 .-. 0`. However, the
result is always equivalent to the input:
<code class="IdrisCode">
<span class="IdrisFunction">ToFromId</span>&nbsp;<span class="IdrisKeyword">:</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">x</span>&nbsp;<span class="IdrisKeyword">:</span>&nbsp;<span class="IdrisType">INT</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisKeyword">-&gt;</span><br />
&nbsp;&nbsp;<span class="IdrisFunction">INTSetoid</span>&nbsp;<span class="IdrisFunction">.equivalence.relation</span><br />
&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisFunction">cast</span>&nbsp;&#36;&nbsp;<span class="IdrisFunction">cast</span>&nbsp;<span class="IdrisKeyword">{</span><span class="IdrisBound">to</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisType">INTEGER</span><span class="IdrisKeyword">}</span>&nbsp;<span class="IdrisBound">x</span><span class="IdrisKeyword">)</span><br />
&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisBound">x</span><br />
<span class="IdrisFunction">ToFromId&apos;</span>&nbsp;<span class="IdrisKeyword">:</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">pos</span><span class="IdrisKeyword">,</span><span class="IdrisBound">neg</span>&nbsp;<span class="IdrisKeyword">:</span>&nbsp;<span class="IdrisType">Nat</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisKeyword">-&gt;</span><br />
&nbsp;&nbsp;<span class="IdrisFunction">INTSetoid</span>&nbsp;<span class="IdrisFunction">.equivalence.relation</span><br />
&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisFunction">cast</span>&nbsp;&#36;&nbsp;<span class="IdrisFunction">cast</span>&nbsp;<span class="IdrisKeyword">{</span><span class="IdrisBound">to</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisType">INTEGER</span><span class="IdrisKeyword">}</span>&nbsp;&#36;&nbsp;<span class="IdrisBound">pos</span>&nbsp;<span class="IdrisData">.-.</span>&nbsp;<span class="IdrisBound">neg</span><span class="IdrisKeyword">)</span><br />
&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">pos</span>&nbsp;<span class="IdrisData">.-.</span>&nbsp;<span class="IdrisBound">neg</span><span class="IdrisKeyword">)</span><br />
<br />
<span class="IdrisFunction">ToFromId&apos;</span>&nbsp;<span class="IdrisBound">pos</span>&nbsp;<span class="IdrisData">0</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisData">Check</span>&nbsp;<span class="IdrisData">Refl</span><br />
<span class="IdrisFunction">ToFromId&apos;</span>&nbsp;<span class="IdrisData">0</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisData">S</span>&nbsp;<span class="IdrisBound">k</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisData">Check</span>&nbsp;<span class="IdrisData">Refl</span><br />
</code>
In the last case, we employ setoid equational reasoning:
<code class="IdrisCode">
<span class="IdrisFunction">ToFromId&apos;</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisData">S</span>&nbsp;<span class="IdrisBound">pos</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisData">S</span>&nbsp;<span class="IdrisBound">neg</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisFunction">CalcWith</span>&nbsp;<span class="IdrisFunction">INTSetoid</span>&nbsp;&#36;<br />
&nbsp;&nbsp;<span class="IdrisData">|~</span>&nbsp;<span class="IdrisFunction">cast</span>&nbsp;<span class="IdrisKeyword">{</span><span class="IdrisBound">from</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisType">INTEGER</span><span class="IdrisKeyword">}</span><br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisFunction">cast</span>&nbsp;&#36;&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisData">S</span>&nbsp;<span class="IdrisBound">pos</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisData">.-.</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisData">S</span>&nbsp;<span class="IdrisBound">neg</span><span class="IdrisKeyword">))</span><br />
&nbsp;&nbsp;<span class="IdrisData">~~</span>&nbsp;<span class="IdrisFunction">cast</span>&nbsp;<span class="IdrisKeyword">{</span><span class="IdrisBound">from</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisType">INTEGER</span><span class="IdrisKeyword">}</span><br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisFunction">cast</span>&nbsp;&#36;&nbsp;<span class="IdrisBound">pos</span>&nbsp;<span class="IdrisData">.-.</span>&nbsp;<span class="IdrisBound">neg</span><span class="IdrisKeyword">)</span><br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisFunction">.=.</span><span class="IdrisKeyword">(</span><span class="IdrisData">Refl</span><span class="IdrisKeyword">)</span><br />
&nbsp;&nbsp;<span class="IdrisData">~~</span>&nbsp;<span class="IdrisBound">pos</span>&nbsp;<span class="IdrisData">.-.</span>&nbsp;<span class="IdrisBound">neg</span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisData">...</span><span class="IdrisKeyword">(</span><span class="IdrisFunction">ToFromId&apos;</span>&nbsp;<span class="IdrisKeyword">\_</span>&nbsp;<span class="IdrisKeyword">\_)</span><br />
&nbsp;&nbsp;<span class="IdrisData">~~</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisData">S</span>&nbsp;<span class="IdrisBound">pos</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisData">.-.</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisData">S</span>&nbsp;<span class="IdrisBound">neg</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisFunction">..&lt;</span><span class="IdrisKeyword">(</span><span class="IdrisFunction">lemma1</span>&nbsp;<span class="IdrisBound">pos</span>&nbsp;<span class="IdrisBound">neg</span>&nbsp;<span class="IdrisData">1</span><span class="IdrisKeyword">)</span><br />
<br />
<span class="IdrisFunction">ToFromId</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">pos</span>&nbsp;<span class="IdrisData">.-.</span>&nbsp;<span class="IdrisBound">neg</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisFunction">ToFromId&apos;</span>&nbsp;<span class="IdrisBound">pos</span>&nbsp;<span class="IdrisBound">neg</span><br />
</code>
Setoid equational reasoning introduces additional 'operation' on the thought
bubble:

* when the middle dot is `=`, we use reflexivity to turn an appropriate
propositional equality `Equal x y` to the setoid relation, with the
operations `(.=.)` and `(.=<)`.

As with homomorphisms, we package setoid isomorphisms into a type and
they too form a setoid:
<code class="IdrisCode">
<span class="IdrisKeyword">record</span>&nbsp;<span class="IdrisType">Isomorphism</span>&nbsp;<span class="IdrisKeyword">{</span><span class="IdrisBound">a</span><span class="IdrisKeyword">,</span>&nbsp;<span class="IdrisBound">b</span>&nbsp;<span class="IdrisKeyword">:</span>&nbsp;<span class="IdrisType">Setoid</span><span class="IdrisKeyword">}</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">Fwd</span>&nbsp;<span class="IdrisKeyword">:</span>&nbsp;<span class="IdrisBound">a</span>&nbsp;<span class="IdrisType">~&gt;</span>&nbsp;<span class="IdrisBound">b</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">Bwd</span>&nbsp;<span class="IdrisKeyword">:</span>&nbsp;<span class="IdrisBound">b</span>&nbsp;<span class="IdrisType">~&gt;</span>&nbsp;<span class="IdrisBound">a</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisKeyword">where</span><br />
&nbsp;&nbsp;constructor&nbsp;<span class="IdrisData">IsIsomorphism</span><br />
&nbsp;&nbsp;<span class="IdrisFunction">BwdFwdId</span>&nbsp;<span class="IdrisKeyword">:</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">a</span>&nbsp;<span class="IdrisFunction">~~&gt;</span>&nbsp;<span class="IdrisBound">a</span><span class="IdrisKeyword">)</span><span class="IdrisFunction">.equivalence.relation</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">Bwd</span>&nbsp;<span class="IdrisFunction">.</span>&nbsp;<span class="IdrisBound">Fwd</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisFunction">id</span>&nbsp;<span class="IdrisBound">a</span><span class="IdrisKeyword">)</span><br />
&nbsp;&nbsp;<span class="IdrisFunction">FwdBwdId</span>&nbsp;<span class="IdrisKeyword">:</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">b</span>&nbsp;<span class="IdrisFunction">~~&gt;</span>&nbsp;<span class="IdrisBound">b</span><span class="IdrisKeyword">)</span><span class="IdrisFunction">.equivalence.relation</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">Fwd</span>&nbsp;<span class="IdrisFunction">.</span>&nbsp;<span class="IdrisBound">Bwd</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisFunction">id</span>&nbsp;<span class="IdrisBound">b</span><span class="IdrisKeyword">)</span><br />
</code>

<code class="IdrisCode">
<span class="IdrisKeyword">record</span>&nbsp;<span class="IdrisType">(&lt;~&gt;)</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">a</span><span class="IdrisKeyword">,</span>&nbsp;<span class="IdrisBound">b</span>&nbsp;<span class="IdrisKeyword">:</span>&nbsp;<span class="IdrisType">Setoid</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisKeyword">where</span><br />
&nbsp;&nbsp;constructor&nbsp;<span class="IdrisData">MkIsomorphism</span><br />
&nbsp;&nbsp;<span class="IdrisFunction">Fwd</span>&nbsp;<span class="IdrisKeyword">:</span>&nbsp;<span class="IdrisBound">a</span>&nbsp;<span class="IdrisType">~&gt;</span>&nbsp;<span class="IdrisBound">b</span><br />
&nbsp;&nbsp;<span class="IdrisFunction">Bwd</span>&nbsp;<span class="IdrisKeyword">:</span>&nbsp;<span class="IdrisBound">b</span>&nbsp;<span class="IdrisType">~&gt;</span>&nbsp;<span class="IdrisBound">a</span><br />
<br />
&nbsp;&nbsp;<span class="IdrisFunction">Iso</span>&nbsp;<span class="IdrisKeyword">:</span>&nbsp;<span class="IdrisType">Isomorphism</span>&nbsp;<span class="IdrisBound">Fwd</span>&nbsp;<span class="IdrisBound">Bwd</span><br />
</code>

and we may form a setoid `a <~~> b` of setoid isomorphisms between the
setoids `a` and `b`, and so on.

Using these concepts, we can package the isomorphism up:
<code class="IdrisCode">
<span class="IdrisFunction">INTEGERisoINT</span>&nbsp;<span class="IdrisKeyword">:</span>&nbsp;<span class="IdrisFunction">INTSetoid</span>&nbsp;<span class="IdrisType">&lt;~&gt;</span>&nbsp;<span class="IdrisFunction">INTEGERSetoid</span><br />
<span class="IdrisFunction">INTEGERisoINT</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisData">MkIsomorphism</span><br />
&nbsp;&nbsp;<span class="IdrisKeyword">{</span>&nbsp;<span class="IdrisBound">Fwd</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisFunction">FromINT</span><br />
&nbsp;&nbsp;<span class="IdrisKeyword">,</span>&nbsp;<span class="IdrisBound">Bwd</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;&nbsp;&nbsp;<span class="IdrisFunction">ToINT</span><br />
&nbsp;&nbsp;<span class="IdrisKeyword">,</span>&nbsp;<span class="IdrisBound">Iso</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisData">IsIsomorphism</span><br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisKeyword">{</span>&nbsp;<span class="IdrisBound">BwdFwdId</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisFunction">ToFromId</span><br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisKeyword">,</span>&nbsp;<span class="IdrisBound">FwdBwdId</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisFunction">FromToId</span><br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisKeyword">}</span><br />
&nbsp;&nbsp;<span class="IdrisKeyword">}</span><br />
</code>

## Arithmetic on `INT`: uniformly algebraic reasoning

One advantage `INT` has over `INTEGER` is that the artihemtic in `INT` is
uniform: we need no case-splitting to define addition and multiplication:
<code class="IdrisCode">
<span class="IdrisFunction">Plus&apos;</span><span class="IdrisKeyword">,</span>&nbsp;<span class="IdrisFunction">Mult&apos;</span>&nbsp;<span class="IdrisKeyword">:</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">x</span><span class="IdrisKeyword">,</span><span class="IdrisBound">y</span>&nbsp;<span class="IdrisKeyword">:</span>&nbsp;<span class="IdrisType">INT</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisKeyword">-&gt;</span>&nbsp;<span class="IdrisType">INT</span><br />
<span class="IdrisBound">x</span>&nbsp;<span class="IdrisFunction">`&nbsp;Plus&apos;&nbsp;`</span>&nbsp;<span class="IdrisBound">y</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">x</span><span class="IdrisFunction">.pos</span>&nbsp;<span class="IdrisFunction">+</span>&nbsp;<span class="IdrisBound">y</span><span class="IdrisFunction">.pos</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisData">.-.</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">x</span><span class="IdrisFunction">.neg</span>&nbsp;<span class="IdrisFunction">+</span>&nbsp;<span class="IdrisBound">y</span><span class="IdrisFunction">.neg</span><span class="IdrisKeyword">)</span><br />
<span class="IdrisBound">x</span>&nbsp;<span class="IdrisFunction">`&nbsp;Mult&apos;&nbsp;`</span>&nbsp;<span class="IdrisBound">y</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">x</span><span class="IdrisFunction">.pos</span>&nbsp;<span class="IdrisFunction">\*</span>&nbsp;<span class="IdrisBound">y</span><span class="IdrisFunction">.pos</span>&nbsp;<span class="IdrisFunction">+</span>&nbsp;<span class="IdrisBound">x</span><span class="IdrisFunction">.neg</span>&nbsp;<span class="IdrisFunction">\*</span>&nbsp;<span class="IdrisBound">y</span><span class="IdrisFunction">.neg</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisData">.-.</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">x</span><span class="IdrisFunction">.pos\*</span><span class="IdrisBound">y</span><span class="IdrisFunction">.neg</span>&nbsp;<span class="IdrisFunction">+</span>&nbsp;<span class="IdrisBound">x</span><span class="IdrisFunction">.neg</span>&nbsp;<span class="IdrisFunction">\*</span>&nbsp;<span class="IdrisBound">y</span><span class="IdrisFunction">.pos</span><span class="IdrisKeyword">)</span><br />
<br />
<span class="IdrisType">Num</span>&nbsp;<span class="IdrisType">INT</span>&nbsp;<span class="IdrisKeyword">where</span><br />
&nbsp;&nbsp;<span class="IdrisFunction">(+)</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisFunction">Plus&apos;</span><br />
&nbsp;&nbsp;<span class="IdrisFunction">(\*)</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisFunction">Mult&apos;</span><br />
&nbsp;&nbsp;<span class="IdrisFunction">fromInteger</span>&nbsp;<span class="IdrisBound">x</span>&nbsp;<span class="IdrisKeyword">=</span><br />
&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisKeyword">if</span>&nbsp;<span class="IdrisBound">x</span>&nbsp;<span class="IdrisFunction">&lt;</span>&nbsp;<span class="IdrisData">0</span><br />
&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisKeyword">then</span>&nbsp;<span class="IdrisData">0</span>&nbsp;<span class="IdrisData">.-.</span>&nbsp;<span class="IdrisFunction">cast</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisFunction">-</span>&nbsp;<span class="IdrisBound">x</span><span class="IdrisKeyword">)</span><br />
&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisKeyword">else</span>&nbsp;<span class="IdrisFunction">cast</span>&nbsp;<span class="IdrisBound">x</span>&nbsp;<span class="IdrisData">.-.</span>&nbsp;<span class="IdrisData">0</span><br />
</code>
Concretely, we can reduce reasoning about these `INT` operations to reasoning
about equational properties of `Nat`. Given a rich simplification suite, such as
[`Frex`](http://www.github.com/frex-project/idris-frex), discharging these
equations is as simple as calling the simplifier. For example, lets construct
the additive commutative monoid over `INT`, complete with the proofs it forms
a commutative monoid that respects the setoid equivalence.
<code class="IdrisCode">
<span class="IdrisFunction">INTMonoid</span>&nbsp;<span class="IdrisKeyword">:</span>&nbsp;<span class="IdrisFunction">CommutativeMonoid</span><br />
<span class="IdrisFunction">INTMonoid</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisFunction">MakeModel</span><br />
</code>
First, we define the structure of an algebra (`INT`, (`+`), `0`)$$:
<code class="IdrisCode">
<br />
&nbsp;&nbsp;<span class="IdrisKeyword">{</span>&nbsp;<span class="IdrisBound">a</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisData">MkSetoidAlgebra</span><br />
&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisKeyword">{</span>&nbsp;<span class="IdrisBound">algebra</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisFunction">MkAlgebra</span><br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisKeyword">{</span>&nbsp;<span class="IdrisBound">U</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisType">INT</span><br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisKeyword">,</span>&nbsp;<span class="IdrisBound">Sem</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisKeyword">\\case</span><br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisData">Neutral</span>&nbsp;<span class="IdrisKeyword">=&gt;</span>&nbsp;<span class="IdrisData">0</span><br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisData">Product</span>&nbsp;<span class="IdrisKeyword">=&gt;</span>&nbsp;<span class="IdrisFunction">(+)</span><br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisKeyword">}</span><br />
</code>
Next, we show the algebra structure is compatible with the setoid structure
`INTSetoid`:
<code class="IdrisCode">
&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisKeyword">,</span>&nbsp;<span class="IdrisBound">equivalence</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisFunction">SameDiffEquivalence</span><br />
&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisKeyword">,</span>&nbsp;<span class="IdrisBound">congruence</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisKeyword">\\case</span><br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisData">MkOp</span>&nbsp;<span class="IdrisData">Neutral</span>&nbsp;<span class="IdrisKeyword">=&gt;</span>&nbsp;<span class="IdrisKeyword">\\</span><span class="IdrisData">[]</span><span class="IdrisKeyword">,</span><span class="IdrisData">[]</span><span class="IdrisKeyword">,</span><span class="IdrisBound">prf</span>&nbsp;<span class="IdrisKeyword">=&gt;</span>&nbsp;<span class="IdrisData">Check</span>&nbsp;<span class="IdrisData">Refl</span><br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisData">MkOp</span>&nbsp;<span class="IdrisData">Product</span>&nbsp;<span class="IdrisKeyword">=&gt;</span>&nbsp;<span class="IdrisKeyword">\\</span><span class="IdrisData">[</span><span class="IdrisBound">x1</span><span class="IdrisData">,</span><span class="IdrisBound">y1</span><span class="IdrisData">]</span><span class="IdrisKeyword">,</span><span class="IdrisData">[</span><span class="IdrisBound">x2</span><span class="IdrisData">,</span><span class="IdrisBound">y2</span><span class="IdrisData">]</span><span class="IdrisKeyword">,</span><span class="IdrisBound">prf</span>&nbsp;<span class="IdrisKeyword">=&gt;</span><br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisKeyword">let</span>&nbsp;<span class="IdrisKeyword">0</span>&nbsp;<span class="IdrisFunction">lemma</span>&nbsp;<span class="IdrisKeyword">:</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">u</span><span class="IdrisKeyword">,</span><span class="IdrisBound">v</span><span class="IdrisKeyword">,</span><span class="IdrisBound">w</span><span class="IdrisKeyword">,</span><span class="IdrisBound">z</span>&nbsp;<span class="IdrisKeyword">:</span>&nbsp;<span class="IdrisType">Nat</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisKeyword">-&gt;</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">u</span>&nbsp;<span class="IdrisFunction">+</span>&nbsp;<span class="IdrisBound">v</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisFunction">+</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">w</span>&nbsp;<span class="IdrisFunction">+</span>&nbsp;<span class="IdrisBound">z</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">u</span>&nbsp;<span class="IdrisFunction">+</span>&nbsp;<span class="IdrisBound">w</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisFunction">+</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">v</span>&nbsp;<span class="IdrisFunction">+</span>&nbsp;<span class="IdrisBound">z</span><span class="IdrisKeyword">)</span><br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisFunction">lemma</span>&nbsp;<span class="IdrisBound">u</span>&nbsp;<span class="IdrisBound">v</span>&nbsp;<span class="IdrisBound">w</span>&nbsp;<span class="IdrisBound">z</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisFunction">solve</span>&nbsp;<span class="IdrisData">4</span><br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisFunction">Monoid.Commutative.Free.Free</span><br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisKeyword">{</span><span class="IdrisBound">a</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisFunction">Nat.Additive</span><span class="IdrisKeyword">}</span>&nbsp;&#36;<br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisKeyword">((</span><span class="IdrisFunction">X</span>&nbsp;<span class="IdrisData">0</span>&nbsp;<span class="IdrisFunction">.+.</span>&nbsp;<span class="IdrisFunction">X</span>&nbsp;<span class="IdrisData">1</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisFunction">.+.</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisFunction">X</span>&nbsp;<span class="IdrisData">2</span>&nbsp;<span class="IdrisFunction">.+.</span>&nbsp;<span class="IdrisFunction">X</span>&nbsp;<span class="IdrisData">3</span><span class="IdrisKeyword">))</span><br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisFunction">=-=</span>&nbsp;<span class="IdrisKeyword">((</span><span class="IdrisFunction">X</span>&nbsp;<span class="IdrisData">0</span>&nbsp;<span class="IdrisFunction">.+.</span>&nbsp;<span class="IdrisFunction">X</span>&nbsp;<span class="IdrisData">2</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisFunction">.+.</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisFunction">X</span>&nbsp;<span class="IdrisData">1</span>&nbsp;<span class="IdrisFunction">.+.</span>&nbsp;<span class="IdrisFunction">X</span>&nbsp;<span class="IdrisData">3</span><span class="IdrisKeyword">))</span><br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisKeyword">in</span>&nbsp;<span class="IdrisData">Check</span>&nbsp;&#36;&nbsp;<span class="IdrisFunction">Calc</span>&nbsp;&#36;<br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisData">|~</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">x1</span><span class="IdrisFunction">.pos</span>&nbsp;<span class="IdrisFunction">+</span>&nbsp;<span class="IdrisBound">y1</span><span class="IdrisFunction">.pos</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisFunction">+</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">x2</span><span class="IdrisFunction">.neg</span>&nbsp;<span class="IdrisFunction">+</span>&nbsp;<span class="IdrisBound">y2</span><span class="IdrisFunction">.neg</span><span class="IdrisKeyword">)</span><br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisData">~~</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">x1</span><span class="IdrisFunction">.pos</span>&nbsp;<span class="IdrisFunction">+</span>&nbsp;<span class="IdrisBound">x2</span><span class="IdrisFunction">.neg</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisFunction">+</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">y1</span><span class="IdrisFunction">.pos</span>&nbsp;<span class="IdrisFunction">+</span>&nbsp;<span class="IdrisBound">y2</span><span class="IdrisFunction">.neg</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisData">...</span><span class="IdrisKeyword">(</span><span class="IdrisFunction">lemma</span>&nbsp;<span class="IdrisKeyword">\_</span>&nbsp;<span class="IdrisKeyword">\_</span>&nbsp;<span class="IdrisKeyword">\_</span>&nbsp;<span class="IdrisKeyword">\_)</span><br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisData">~~</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">x2</span><span class="IdrisFunction">.pos</span>&nbsp;<span class="IdrisFunction">+</span>&nbsp;<span class="IdrisBound">x1</span><span class="IdrisFunction">.neg</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisFunction">+</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">y2</span><span class="IdrisFunction">.pos</span>&nbsp;<span class="IdrisFunction">+</span>&nbsp;<span class="IdrisBound">y1</span><span class="IdrisFunction">.neg</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisData">...</span><span class="IdrisKeyword">(</span><span class="IdrisFunction">cong2</span>&nbsp;<span class="IdrisFunction">(+)</span><br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">prf</span>&nbsp;<span class="IdrisData">0</span><span class="IdrisKeyword">)</span><span class="IdrisFunction">.same</span><br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">prf</span>&nbsp;<span class="IdrisData">1</span><span class="IdrisKeyword">)</span><span class="IdrisFunction">.same</span><span class="IdrisKeyword">)</span><br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisData">~~</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">x2</span><span class="IdrisFunction">.pos</span>&nbsp;<span class="IdrisFunction">+</span>&nbsp;<span class="IdrisBound">y2</span><span class="IdrisFunction">.pos</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisFunction">+</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">x1</span><span class="IdrisFunction">.neg</span>&nbsp;<span class="IdrisFunction">+</span>&nbsp;<span class="IdrisBound">y1</span><span class="IdrisFunction">.neg</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisData">...</span><span class="IdrisKeyword">(</span><span class="IdrisFunction">lemma</span>&nbsp;<span class="IdrisKeyword">\_</span>&nbsp;<span class="IdrisKeyword">\_</span>&nbsp;<span class="IdrisKeyword">\_</span>&nbsp;<span class="IdrisKeyword">\_)</span><br />
&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisKeyword">}</span><br />
</code>
Finally, we prove the commutative monoid axioms by calling `Frex`:
<code class="IdrisCode">
&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisKeyword">,</span>&nbsp;<span class="IdrisBound">validate</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisKeyword">\\case</span><br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisData">Mon</span>&nbsp;<span class="IdrisData">LftNeutrality</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisKeyword">=&gt;</span>&nbsp;<span class="IdrisKeyword">\\</span><span class="IdrisData">[</span><span class="IdrisBound">p</span>&nbsp;<span class="IdrisData">.-.</span>&nbsp;<span class="IdrisBound">n</span><span class="IdrisData">]</span>&nbsp;<span class="IdrisKeyword">=&gt;</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisFunction">INTSetoid</span><span class="IdrisKeyword">)</span><span class="IdrisFunction">.equivalence.reflexive</span>&nbsp;<span class="IdrisKeyword">\_</span><br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisData">Mon</span>&nbsp;<span class="IdrisData">RgtNeutrality</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisKeyword">=&gt;</span>&nbsp;<span class="IdrisKeyword">\\</span><span class="IdrisData">[</span><span class="IdrisBound">p</span>&nbsp;<span class="IdrisData">.-.</span>&nbsp;<span class="IdrisBound">n</span><span class="IdrisData">]</span>&nbsp;<span class="IdrisKeyword">=&gt;</span>&nbsp;<span class="IdrisData">Check</span>&nbsp;&#36;&nbsp;<span class="IdrisFunction">Calc</span>&nbsp;&#36;<br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisData">|~</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">p</span>&nbsp;<span class="IdrisFunction">+</span>&nbsp;<span class="IdrisData">0</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisFunction">+</span>&nbsp;<span class="IdrisBound">n</span><br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisData">~~</span>&nbsp;<span class="IdrisBound">p</span>&nbsp;<span class="IdrisFunction">+</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">n</span>&nbsp;<span class="IdrisFunction">+</span>&nbsp;<span class="IdrisData">0</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisData">...</span><span class="IdrisKeyword">(</span><span class="IdrisFunction">solve</span>&nbsp;<span class="IdrisData">2</span><br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisFunction">Monoid.Commutative.Free.Free</span><br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisKeyword">{</span><span class="IdrisBound">a</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisFunction">Nat.Additive</span><span class="IdrisKeyword">}</span>&nbsp;&#36;<br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisKeyword">((</span><span class="IdrisFunction">X</span>&nbsp;<span class="IdrisData">0</span>&nbsp;<span class="IdrisFunction">.+.</span>&nbsp;<span class="IdrisFunction">O1</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisFunction">.+.</span>&nbsp;<span class="IdrisFunction">X</span>&nbsp;<span class="IdrisData">1</span><span class="IdrisKeyword">)</span><br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisFunction">=-=</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisFunction">X</span>&nbsp;<span class="IdrisData">0</span>&nbsp;<span class="IdrisFunction">.+.</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisFunction">X</span>&nbsp;<span class="IdrisData">1</span>&nbsp;<span class="IdrisFunction">.+.</span>&nbsp;<span class="IdrisFunction">O1</span><span class="IdrisKeyword">)))</span><br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisData">Mon</span>&nbsp;<span class="IdrisData">Associativity</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisKeyword">=&gt;</span>&nbsp;<span class="IdrisKeyword">\\</span><span class="IdrisData">[</span><span class="IdrisBound">p1</span>&nbsp;<span class="IdrisData">.-.</span>&nbsp;<span class="IdrisBound">n1</span><span class="IdrisData">,</span>&nbsp;<span class="IdrisBound">p2</span>&nbsp;<span class="IdrisData">.-.</span>&nbsp;<span class="IdrisBound">n2</span><span class="IdrisData">,</span>&nbsp;<span class="IdrisBound">p3</span>&nbsp;<span class="IdrisData">.-.</span>&nbsp;<span class="IdrisBound">n3</span><span class="IdrisData">]</span>&nbsp;<span class="IdrisKeyword">=&gt;</span>&nbsp;<span class="IdrisData">Check</span>&nbsp;&#36;&nbsp;<span class="IdrisFunction">Calc</span>&nbsp;&#36;<br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisData">|~</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">p1</span>&nbsp;<span class="IdrisFunction">+</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">p2</span>&nbsp;<span class="IdrisFunction">+</span>&nbsp;<span class="IdrisBound">p3</span><span class="IdrisKeyword">))</span>&nbsp;<span class="IdrisFunction">+</span>&nbsp;<span class="IdrisKeyword">((</span><span class="IdrisBound">n1</span>&nbsp;<span class="IdrisFunction">+</span>&nbsp;<span class="IdrisBound">n2</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisFunction">+</span>&nbsp;<span class="IdrisBound">n3</span><span class="IdrisKeyword">)</span><br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisData">~~</span>&nbsp;<span class="IdrisKeyword">((</span><span class="IdrisBound">p1</span>&nbsp;<span class="IdrisFunction">+</span>&nbsp;<span class="IdrisBound">p2</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisFunction">+</span>&nbsp;<span class="IdrisBound">p3</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisFunction">+</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">n1</span>&nbsp;<span class="IdrisFunction">+</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">n2</span>&nbsp;<span class="IdrisFunction">+</span>&nbsp;<span class="IdrisBound">n3</span><span class="IdrisKeyword">))</span><br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisData">...</span><span class="IdrisKeyword">(</span><span class="IdrisFunction">solve</span>&nbsp;<span class="IdrisData">6</span>&nbsp;<span class="IdrisFunction">Monoid.Commutative.Free.Free</span>&nbsp;<span class="IdrisKeyword">{</span><span class="IdrisBound">a</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisFunction">Nat.Additive</span><span class="IdrisKeyword">}</span>&nbsp;&#36;<br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisFunction">X</span>&nbsp;<span class="IdrisData">0</span>&nbsp;<span class="IdrisFunction">.+.</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisFunction">X</span>&nbsp;<span class="IdrisData">1</span>&nbsp;<span class="IdrisFunction">.+.</span>&nbsp;<span class="IdrisFunction">X</span>&nbsp;<span class="IdrisData">2</span><span class="IdrisKeyword">))</span>&nbsp;<span class="IdrisFunction">.+.</span>&nbsp;<span class="IdrisKeyword">((</span><span class="IdrisFunction">X</span>&nbsp;<span class="IdrisData">3</span>&nbsp;<span class="IdrisFunction">.+.</span>&nbsp;<span class="IdrisFunction">X</span>&nbsp;<span class="IdrisData">4</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisFunction">.+.</span>&nbsp;<span class="IdrisFunction">X</span>&nbsp;<span class="IdrisData">5</span><span class="IdrisKeyword">)</span><br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisFunction">=-=</span>&nbsp;<span class="IdrisKeyword">((</span><span class="IdrisFunction">X</span>&nbsp;<span class="IdrisData">0</span>&nbsp;<span class="IdrisFunction">.+.</span>&nbsp;<span class="IdrisFunction">X</span>&nbsp;<span class="IdrisData">1</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisFunction">.+.</span>&nbsp;<span class="IdrisFunction">X</span>&nbsp;<span class="IdrisData">2</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisFunction">.+.</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisFunction">X</span>&nbsp;<span class="IdrisData">3</span>&nbsp;<span class="IdrisFunction">.+.</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisFunction">X</span>&nbsp;<span class="IdrisData">4</span>&nbsp;<span class="IdrisFunction">.+.</span>&nbsp;<span class="IdrisFunction">X</span>&nbsp;<span class="IdrisData">5</span><span class="IdrisKeyword">))</span><br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisKeyword">)</span><br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisData">Commutativity</span>&nbsp;<span class="IdrisKeyword">=&gt;</span>&nbsp;<span class="IdrisKeyword">\\</span><span class="IdrisData">[</span><span class="IdrisBound">p1</span>&nbsp;<span class="IdrisData">.-.</span>&nbsp;<span class="IdrisBound">n1</span><span class="IdrisData">,</span>&nbsp;<span class="IdrisBound">p2</span>&nbsp;<span class="IdrisData">.-.</span>&nbsp;<span class="IdrisBound">n2</span><span class="IdrisData">]</span>&nbsp;<span class="IdrisKeyword">=&gt;</span>&nbsp;<span class="IdrisData">Check</span>&nbsp;&#36;&nbsp;<span class="IdrisFunction">Calc</span>&nbsp;&#36;<br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisData">|~</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">p1</span>&nbsp;<span class="IdrisFunction">+</span>&nbsp;<span class="IdrisBound">p2</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisFunction">+</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">n2</span>&nbsp;<span class="IdrisFunction">+</span>&nbsp;<span class="IdrisBound">n1</span><span class="IdrisKeyword">)</span><br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisData">~~</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">p2</span>&nbsp;<span class="IdrisFunction">+</span>&nbsp;<span class="IdrisBound">p1</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisFunction">+</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">n1</span>&nbsp;<span class="IdrisFunction">+</span>&nbsp;<span class="IdrisBound">n2</span><span class="IdrisKeyword">)</span><br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisData">...</span><span class="IdrisKeyword">(</span><span class="IdrisFunction">solve</span>&nbsp;<span class="IdrisData">4</span>&nbsp;<span class="IdrisFunction">Monoid.Commutative.Free.Free</span>&nbsp;<span class="IdrisKeyword">{</span><span class="IdrisBound">a</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisFunction">Nat.Additive</span><span class="IdrisKeyword">}</span>&nbsp;&#36;<br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisKeyword">((</span><span class="IdrisFunction">X</span>&nbsp;<span class="IdrisData">0</span>&nbsp;<span class="IdrisFunction">.+.</span>&nbsp;<span class="IdrisFunction">X</span>&nbsp;<span class="IdrisData">1</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisFunction">.+.</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisFunction">X</span>&nbsp;<span class="IdrisData">2</span>&nbsp;<span class="IdrisFunction">.+.</span>&nbsp;<span class="IdrisFunction">X</span>&nbsp;<span class="IdrisData">3</span><span class="IdrisKeyword">))</span><br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="IdrisFunction">=-=</span>&nbsp;<span class="IdrisKeyword">((</span><span class="IdrisFunction">X</span>&nbsp;<span class="IdrisData">1</span>&nbsp;<span class="IdrisFunction">.+.</span>&nbsp;<span class="IdrisFunction">X</span>&nbsp;<span class="IdrisData">0</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisFunction">.+.</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisFunction">X</span>&nbsp;<span class="IdrisData">3</span>&nbsp;<span class="IdrisFunction">.+.</span>&nbsp;<span class="IdrisFunction">X</span>&nbsp;<span class="IdrisData">2</span><span class="IdrisKeyword">)))</span><br />
&nbsp;&nbsp;<span class="IdrisKeyword">}</span><br />
</code>
Assuming we have a semi-ring simplifier for the arithmetic structure over the
natural numbers $(\mathbb N, (+), 0, (\cdot), 1)$, we can similarly uniformly
construct the multiplicative integers and the resulting ring.

## Transporting structure
<code class="IdrisCode">
<span class="IdrisKeyword">0</span>&nbsp;<span class="IdrisFunction">BinOp</span>&nbsp;<span class="IdrisKeyword">:</span>&nbsp;<span class="IdrisType">Setoid</span>&nbsp;<span class="IdrisKeyword">-&gt;</span>&nbsp;<span class="IdrisType">Type</span><br />
<span class="IdrisFunction">BinOp</span>&nbsp;<span class="IdrisBound">a</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisFunction">U</span>&nbsp;<span class="IdrisBound">a</span>&nbsp;<span class="IdrisKeyword">-&gt;</span>&nbsp;<span class="IdrisFunction">U</span>&nbsp;<span class="IdrisBound">a</span>&nbsp;<span class="IdrisKeyword">-&gt;</span>&nbsp;<span class="IdrisFunction">U</span>&nbsp;<span class="IdrisBound">a</span><span class="IdrisKeyword">)</span><br />
<br />
<span class="IdrisKeyword">0</span>&nbsp;<span class="IdrisFunction">Preserves</span>&nbsp;<span class="IdrisKeyword">:</span>&nbsp;<span class="IdrisType">(</span><span class="IdrisBound">a</span>&nbsp;<span class="IdrisKeyword">:</span>&nbsp;<span class="IdrisType">Setoid</span>&nbsp;<span class="IdrisType">\*\*</span>&nbsp;<span class="IdrisFunction">BinOp</span>&nbsp;<span class="IdrisBound">a</span><span class="IdrisType">)</span>&nbsp;<span class="IdrisKeyword">-&gt;</span>&nbsp;<span class="IdrisType">(</span><span class="IdrisBound">b</span>&nbsp;<span class="IdrisKeyword">:</span>&nbsp;<span class="IdrisType">Setoid</span>&nbsp;<span class="IdrisType">\*\*</span>&nbsp;<span class="IdrisFunction">BinOp</span>&nbsp;<span class="IdrisBound">b</span><span class="IdrisType">)</span>&nbsp;<span class="IdrisKeyword">-&gt;</span><br />
&nbsp;&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisFunction">U</span>&nbsp;<span class="IdrisBound">a</span>&nbsp;<span class="IdrisKeyword">-&gt;</span>&nbsp;<span class="IdrisFunction">U</span>&nbsp;<span class="IdrisBound">b</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisKeyword">-&gt;</span>&nbsp;<span class="IdrisType">Type</span><br />
<span class="IdrisKeyword">(</span>(<span class="IdrisBound">a</span>&nbsp;<span class="IdrisData">\*\*</span>&nbsp;<span class="IdrisBound">fa</span>)&nbsp;<span class="IdrisFunction">`Preserves`</span>&nbsp;(<span class="IdrisBound">b</span>&nbsp;<span class="IdrisData">\*\*</span>&nbsp;<span class="IdrisBound">fb</span>)<span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisBound">h</span>&nbsp;<span class="IdrisKeyword">=</span><br />
&nbsp;&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">x</span><span class="IdrisKeyword">,</span><span class="IdrisBound">y</span>&nbsp;<span class="IdrisKeyword">:</span>&nbsp;<span class="IdrisFunction">U</span>&nbsp;<span class="IdrisBound">a</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisKeyword">-&gt;</span>&nbsp;<span class="IdrisBound">h</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">x</span>&nbsp;<span class="IdrisBound">`fa`</span>&nbsp;<span class="IdrisBound">y</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisKeyword">=</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">h</span>&nbsp;<span class="IdrisBound">x</span><span class="IdrisKeyword">)</span>&nbsp;<span class="IdrisBound">`fb`</span>&nbsp;<span class="IdrisKeyword">(</span><span class="IdrisBound">h</span>&nbsp;<span class="IdrisBound">y</span><span class="IdrisKeyword">)</span><br />
<br />
<span class="IdrisComment">--toINTisAddHomo&nbsp;:&nbsp;(INTSetoid&nbsp;\*\*&nbsp;(+))</span><br />
<br />
</code>

