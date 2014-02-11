angular.module("asset.common.partials.wiz", [])

.directive "wizForm", ->
  restrict: "E"
  templateUrl: "common/partials/templates/wiz-form.tpl.html"
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