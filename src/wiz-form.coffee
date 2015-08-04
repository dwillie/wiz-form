angular.module("wiz", [])

.directive "wizForm", ->
  restrict: "E"
  template: """
<div class="wizard-body">

  <div ng-transclude class="inner">
  </div>

  <div ng-show="steps[currentStep].show_controls()">

    <div class="wizard-control previous">
      <button class="wizard-btn previous" ng-click="previousStep()" ng-show="currentStep > 0">
        {{ previousText() || 'Previous' }}
      </button>
    </div>

    <div class="wizard-control next">
      <div class="error">
        <span ng-show="isError()">{{ message.error }}</span>
        <button class="wizard-btn next" ng-click="nextStep()" ng-hide="lastStep()">
          {{ nextText() || 'Next' }}
        </button>
        <button class="wizard-btn finish" ng-click="nextStep()" ng-show="lastStep()">
          {{ nextText() || 'Finish' }}
        </button>
      </div>
    </div>

  </div>
</div>
"""
  transclude: true
  replace: true
  scope: {
    onFinish: "&"
    wizardMeta: "="
  }
  controller: ($scope) ->
    $scope.steps       = []
    $scope.currentStep = 0
    if $scope.wizardMeta?
      $scope.wizardMeta.activeStep = 0

    @registerStep = (stepObject) ->
      $scope.steps.push stepObject
      if $scope.wizardMeta
        $scope.wizardMeta.totalSteps = $scope.steps.length
        if $scope.steps.length == 1
          $scope.wizardMeta.activeStepName = $scope.steps[0].name

      return $scope.steps.length - 1

    @getCurrentStep = ->
      $scope.currentStep

    $scope.nextText = ->
      if $scope.steps[$scope.currentStep] && $scope.steps[$scope.currentStep].next_text
        $scope.steps[$scope.currentStep].next_text
      else
        false
    $scope.previousText = ->
      if $scope.steps[$scope.currentStep] && $scope.steps[$scope.currentStep].previous_text
        $scope.steps[$scope.currentStep].previous_text
      else
        false

    $scope.isError = ->
      $scope.message? && $scope.message.error?
    $scope.previousStep = ->
      $scope.currentStep -= 1 if $scope.currentStep > 0
    $scope.lastStep = ->
      $scope.currentStep >= $scope.steps.length - 1
    $scope.nextStep = ->
      $scope.message = undefined
      readyCheck = $scope.steps[$scope.currentStep].ready_check
      if readyCheck?
        $scope.message = readyCheck()
        if $scope.isError()
          return

      if $scope.lastStep()
        if $scope.onFinish
          $scope.onFinish()
      else
        $scope.currentStep += 1

    $scope.$watch 'currentStep', ->
      if $scope.wizardMeta && $scope.steps[$scope.currentStep]
        $scope.wizardMeta.activeStep     = $scope.currentStep
        $scope.wizardMeta.activeStepName = $scope.steps[$scope.currentStep].name

    $scope.$watch 'wizardMeta.activeStep', ->
      unless $scope.wizardMeta?
        return

      while $scope.currentStep < $scope.wizardMeta.activeStep
        $scope.nextStep()
        if $scope.isError()
          break
      while $scope.currentStep > $scope.wizardMeta.activeStep
        $scope.previousStep()
        if $scope.isError()
          break

      # If there was an error, the activestep and name will be wrong in the wizard meta as they will be what the
      # external source set them to.
      if $scope.isError()
        $scope.wizardMeta.activeStep     = $scope.currentStep
        $scope.wizardMeta.activeStepName = $scope.steps[$scope.currentStep].name

    $scope.$watch 'wizardMeta.activeStepName', ->
      unless $scope.wizardMeta?
        return

      if $scope.steps[$scope.currentStep].name != $scope.wizardMeta.activeStepName
        for step, i in $scope.steps
          if step.name == $scope.wizardMeta.activeStepName
            $scope.wizardMeta.activeStep = i

    return this

.directive "wizStep", ->
  restrict:    "E"
  template: "<div ng-show='wizFormCtrl.getCurrentStep() == stepIndex'><div ng-transclude></div></div>"
  transclude:  true
  replace:     true
  require: "^wizForm"
  scope:
    readyCheck:   "&"
    nextText:     "@"
    previousText: "@"
    showControls: "&"
  link: ($scope, elem, attrs, wizFormCtrl) ->
    $scope.wizFormCtrl = wizFormCtrl
    unless attrs.readyCheck
      $scope.readyCheck = null
    unless attrs.showControls
      $scope.showControls = -> true
    $scope.stepIndex = wizFormCtrl.registerStep({
      name:          attrs.name,
      element:       elem,
      ready_check:   $scope.readyCheck,
      next_text:     $scope.nextText,
      previous_text: $scope.previousText,
      show_controls: $scope.showControls
    })
