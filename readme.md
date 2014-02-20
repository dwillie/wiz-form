wiz-form
========

wiz-form is an AngularJS directive which provides a super simple and easily extensible wizard. It's not a form by necessity so... pending rename?

wiz-form supports the following:

* Automatically calling a function at the end of the wizard
* 'ReadyCheck' to determine whether the user should be able to proceed to the next step (expression/function)
* Error messages on failed ready-check
* Next/Previous/Finish button text override
* Step naming
* wizard-meta allowing access to internal wizard info, current step index, total number of steps and 'name' of the current step, as well as controlling the form by changing wizardMeta.activeStep / activeStepName
* Everything optional with (hopefully) reasonable defaults

Happy to hear suggestions on the direction of wiz

Install
-------

    bower install wiz-form

That'll do the trick. If you're looking for a specific version check the tags on this repo and tack it on the end e.g.

    bower install wiz-form 0.0.4

Then just whack it in your module...

```coffeescript
angular.module('myModule', [
  'wiz'
])
```

And you're ready to use it.

Usage
-----
```html
<wiz-form>
    <wiz-step>
        <p>This is step one!</p>
    </wiz-step>
    <wiz-step>
        <p>This is step two!</p>
    </wiz-step>
</wiz-form>
```

That's it. Wizard complete. We can customize it to our will if we like!
```html
<h1>{{ wizardMeta.activeStepName }}</h1>
<wiz-form wizard-meta="wizardMeta">
    <wiz-step name="Step One!">
        <p>This is step one!</p>
    </wiz-step>
    <wiz-step name="Step Two!">
        <p>This is step two!</p>
    </wiz-step>
</wiz-form>
```

That'll show the name of the active step in the h1 tag at the top. We can also access the current step and step counts through wizard-meta too, which is two-way bound. Changes you make to the wizardMeta activeStep and activeStepName will affect the wizard's state.

If we wanted to use a progress bar instead of a title, we could look at the Bootstrap bars...

```html
<div class="progress-bar" role="progressbar"
     aria-valuenow="{{ wizardMeta.activeStep }}"
     aria-valuemin="0"
     aria-valuemax="{{ wizardMeta.totalSteps }}">
</div>
<wiz-form wizard-meta="wizardMeta">
    <wiz-step>
        <p>0%</p>
    </wiz-step>
    <wiz-step>
        <p>25%</p>
    </wiz-step>
    <wiz-step>
        <p>50%</p>
    </wiz-step>
    <wiz-step>
        <p>75%</p>
    </wiz-step>
</wiz-form>
```
    
Or something to that effect.

We can display errors and disable the next button with the ready-check property for wiz-step.

```html
<wiz-form wizard-meta="wizardMeta">
    <wiz-step ready-check="myValidation()">
        <p>This is step one!</p>
    </wiz-step>
    <wiz-step name="Step Two!">
        <p>This is step two!</p>
    </wiz-step>
</wiz-form>
```
    
By returning an Object with an 'error' member on our scope, we can specify an error message to be displayed.

```coffeescript
myValidation = ->
    if somethingIsValid()
        return {}
    else
        return { error: "You dun goof'd!" }
```

Room for refinement on that one.

We can also rename our buttons, too

```html
<wiz-form wizard-meta="wizardMeta">
    <wiz-step>
        <p>This is step one!</p>
    </wiz-step>
    <wiz-step next-text="GO!" previous-text="UNGO!">
        <p>This is step two!</p>
    </wiz-step>
</wiz-form>
```

We can also specify a on-finish attribute at the wiz-form level

```html
<wiz-form on-finish="saveData()">
</wiz-form>
```

It works with ngRepeat

```html
<wiz-form on-finish="saveData()">
    <div ng-repeat="foo in bars">
        <wiz-step>
            {{ foo }}!
        </wiz-step>
    </div>
</wiz-form>
```

Or your own directives...

```html
<wiz-form wizard-meta="wizardMeta">
    <wiz-step>
        <something></something>
    </wiz-step>
</wiz-form>
```
