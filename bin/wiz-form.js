angular.module('wiz', []).directive('wizForm', function () {
  return {
    restrict: 'E',
    template: '<div class="wizard-body">\n  \n  <div ng-transclude class="inner">\n  </div>\n\n  <div class="row">\n\n    <div class="pull-left">\n      <button class="btn btn-default" ng-click="previousStep()" ng-show="currentStep > 0">\n        {{ previousText() || \'Previous\' }}\n      </button>\n    </div>\n\n    <div class="pull-right">\n      <div class="row error">\n        <span ng-show="isError"><i class="fa fa-exclamation-triangle"></i>{{ message.error }}</span>\n        <button class="btn btn-primary" ng-click="nextStep()">\n          <span ng-hide="lastStep()">{{ nextText() || \'Next\' }}</span>\n          <span ng-show="lastStep()">{{ nextText() || \'Finish\' }}</span>\n        </button>\n      </div>\n    </div>\n\n  </div>\n</div>',
    transclude: true,
    replace: true,
    scope: {
      onFinish: '&',
      wizardMeta: '='
    },
    controller: [
      '$scope',
      function ($scope) {
        $scope.steps = [];
        $scope.currentStep = 0;
        this.registerStep = function (stepObject) {
          $scope.steps.push(stepObject);
          if ($scope.wizardMeta) {
            $scope.wizardMeta.totalSteps = $scope.steps.length;
          }
          return $scope.steps.length - 1;
        };
        this.getCurrentStep = function () {
          return $scope.currentStep;
        };
        $scope.nextText = function () {
          if ($scope.steps[$scope.currentStep] && $scope.steps[$scope.currentStep].next_text) {
            return $scope.steps[$scope.currentStep].next_text;
          } else {
            return false;
          }
        };
        $scope.previousText = function () {
          if ($scope.steps[$scope.currentStep] && $scope.steps[$scope.currentStep].previous_text) {
            return $scope.steps[$scope.currentStep].previous_text;
          } else {
            return false;
          }
        };
        $scope.isError = function () {
          return $scope.message != null && $scope.message.error != null;
        };
        $scope.previousStep = function () {
          if ($scope.currentStep > 0) {
            return $scope.currentStep -= 1;
          }
        };
        $scope.lastStep = function () {
          return $scope.currentStep >= $scope.steps.length - 1;
        };
        $scope.nextStep = function () {
          var readyCheck;
          readyCheck = $scope.steps[$scope.currentStep].ready_check;
          if (readyCheck != null) {
            $scope.message = readyCheck();
          }
          if ($scope.isError()) {
            return;
          }
          $scope.message = null;
          if ($scope.lastStep()) {
            if ($scope.onFinish) {
              return $scope.onFinish();
            }
          } else {
            return $scope.currentStep += 1;
          }
        };
        $scope.$watch('currentStep', function () {
          if ($scope.wizardMeta && $scope.steps[$scope.currentStep] && $scope.steps[$scope.currentStep].name) {
            $scope.wizardMeta.activeStep = $scope.currentStep;
            return $scope.wizardMeta.activeStepName = $scope.steps[$scope.currentStep].name;
          }
        });
        return this;
      }
    ]
  };
}).directive('wizStep', function () {
  return {
    restrict: 'E',
    template: '<div ng-show=\'wizFormCtrl.getCurrentStep() == stepIndex\'><div ng-transclude></div></div>',
    transclude: true,
    replace: true,
    require: '^wizForm',
    scope: {
      readyCheck: '&',
      nextText: '@',
      previousText: '@'
    },
    link: function ($scope, elem, attrs, wizFormCtrl) {
      $scope.wizFormCtrl = wizFormCtrl;
      if (!attrs.readyCheck) {
        $scope.readyCheck = null;
      }
      return $scope.stepIndex = wizFormCtrl.registerStep({
        name: attrs.name,
        element: elem,
        ready_check: $scope.readyCheck,
        next_text: $scope.nextText,
        previous_text: $scope.previousText
      });
    }
  };
});