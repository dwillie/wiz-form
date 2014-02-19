angular.module("wiz", [])

.directive "wizForm", ->
  restrict: "E"
  template: """
<div class="wizard-body">
  
  <div ng-transclude class="inner">
  </div>

  <div>

    <div class="wizard-left-block">
      <button class="btn-wizard-previous" ng-click="previousStep()" ng-show="currentStep > 0">
        {{ previousText() || 'Previous' }}
      </button>
    </div>

    <div class="wizard-right-block">
      <div class="wizard-error">
        <span ng-show="isError()">{{ message.error }}</span>
        <button class="btn-wizard-next" ng-click="nextStep()" ng-hide="lastStep()">
          {{ nextText() || 'Next' }}
        </button>
        <button class="btn-wizard-finish" ng-click="nextStep()" ng-show="lastStep()">
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

    @registerStep = (stepObject) ->
      $scope.steps.push stepObject
      if $scope.wizardMeta
        $scope.wizardMeta.totalSteps = $scope.steps.length

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
      readyCheck = $scope.steps[$scope.currentStep].ready_check
      if readyCheck?
        $scope.message = readyCheck()
      if $scope.isError()
        return

      $scope.message = null
      if $scope.lastStep()
        if $scope.onFinish
          $scope.onFinish()
      else
        $scope.currentStep += 1

    $scope.$watch 'currentStep', ->
      if $scope.wizardMeta && $scope.steps[$scope.currentStep] && $scope.steps[$scope.currentStep].name
        $scope.wizardMeta.activeStep     = $scope.currentStep
        $scope.wizardMeta.activeStepName = $scope.steps[$scope.currentStep].name

    $scope.$watch 'wizardMeta.activeStep', ->
      unless $scope.wizardMeta?
        return

      while $scope.currentStep < $scope.wizardMeta.activeStep && !$scope.isError()
        $scope.nextStep()
      while $scope.currentStep > $scope.wizardMeta.activeStep && !$scope.isError()
        $scope.previousStep()

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
  link: ($scope, elem, attrs, wizFormCtrl) ->
    $scope.wizFormCtrl = wizFormCtrl
    unless attrs.readyCheck
      $scope.readyCheck = null
    $scope.stepIndex = wizFormCtrl.registerStep({
      name:          attrs.name,
      element:       elem,
      ready_check:   $scope.readyCheck
      next_text:     $scope.nextText
      previous_text: $scope.previousText
    })