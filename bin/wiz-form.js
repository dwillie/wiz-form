angular.module('wiz', []).directive('wizForm', function () {
  return {
    restrict: 'E',
    template: '<div class="wizard-body">\n\n  <div ng-transclude class="inner">\n  </div>\n\n  <div ng-show="steps[currentStep].show_controls()">\n\n    <div class="wizard-control previous">\n      <button class="wizard-btn previous" ng-click="previousStep()" ng-show="currentStep > 0">\n        {{ previousText() || \'Previous\' }}\n      </button>\n    </div>\n\n    <div class="wizard-control next">\n      <div class="error">\n        <span ng-show="isError()">{{ message.error }}</span>\n        <button class="wizard-btn next" ng-click="nextStep()" ng-hide="lastStep()">\n          {{ nextText() || \'Next\' }}\n        </button>\n        <button class="wizard-btn finish" ng-click="nextStep()" ng-show="lastStep()">\n          {{ nextText() || \'Finish\' }}\n        </button>\n      </div>\n    </div>\n\n  </div>\n</div>',
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
        if ($scope.wizardMeta != null) {
          $scope.wizardMeta.activeStep = 0;
        }
        this.registerStep = function (stepObject) {
          $scope.steps.push(stepObject);
          if ($scope.wizardMeta) {
            $scope.wizardMeta.totalSteps = $scope.steps.length;
            if ($scope.steps.length === 1) {
              $scope.wizardMeta.activeStepName = $scope.steps[0].name;
            }
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
          $scope.message = void 0;
          readyCheck = $scope.steps[$scope.currentStep].ready_check;
          if (readyCheck != null) {
            $scope.message = readyCheck();
            if ($scope.isError()) {
              return;
            }
          }
          if ($scope.lastStep()) {
            if ($scope.onFinish) {
              return $scope.onFinish();
            }
          } else {
            return $scope.currentStep += 1;
          }
        };
        $scope.$watch('currentStep', function () {
          if ($scope.wizardMeta && $scope.steps[$scope.currentStep]) {
            $scope.wizardMeta.activeStep = $scope.currentStep;
            return $scope.wizardMeta.activeStepName = $scope.steps[$scope.currentStep].name;
          }
        });
        $scope.$watch('wizardMeta.activeStep', function () {
          if ($scope.wizardMeta == null) {
            return;
          }
          while ($scope.currentStep < $scope.wizardMeta.activeStep) {
            $scope.nextStep();
            if ($scope.isError()) {
              break;
            }
          }
          while ($scope.currentStep > $scope.wizardMeta.activeStep) {
            $scope.previousStep();
            if ($scope.isError()) {
              break;
            }
          }
          if ($scope.isError()) {
            $scope.wizardMeta.activeStep = $scope.currentStep;
            return $scope.wizardMeta.activeStepName = $scope.steps[$scope.currentStep].name;
          }
        });
        $scope.$watch('wizardMeta.activeStepName', function () {
          var i, step, _i, _len, _ref, _results;
          if ($scope.wizardMeta == null) {
            return;
          }
          if ($scope.steps[$scope.currentStep].name !== $scope.wizardMeta.activeStepName) {
            _ref = $scope.steps;
            _results = [];
            for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
              step = _ref[i];
              if (step.name === $scope.wizardMeta.activeStepName) {
                _results.push($scope.wizardMeta.activeStep = i);
              } else {
                _results.push(void 0);
              }
            }
            return _results;
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
      previousText: '@',
      showControls: '&'
    },
    link: function ($scope, elem, attrs, wizFormCtrl) {
      $scope.wizFormCtrl = wizFormCtrl;
      if (!attrs.readyCheck) {
        $scope.readyCheck = null;
      }
      if (!attrs.showControls) {
        $scope.showControls = function () {
          return true;
        };
      }
      return $scope.stepIndex = wizFormCtrl.registerStep({
        name: attrs.name,
        element: elem,
        ready_check: $scope.readyCheck,
        next_text: $scope.nextText,
        previous_text: $scope.previousText,
        show_controls: $scope.showControls
      });
    }
  };
});