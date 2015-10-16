module Test.Spec.ReporterSpec where

import Prelude

import Control.Monad.Eff.Exception (error)
import Data.Foldable               (mconcat)

import           Test.Spec            ( Group(..)
                                      , Result(..)
                                      , collect
                                      , await
                                      , describe
                                      , it
                                      )
import           Test.Spec.Assertions (shouldEqual)
import qualified Test.Spec.Reporter   as R

import Test.Spec.Fixtures ( failureTest
                          , pendingTest
                          , sharedDescribeTest
                          , successTest
                          )

reporterSpec =
  describe "Test" $
    describe "Spec" $
      describe "Reporter" do
        it "collapses groups into entries with names" do
          results <- collect successTest >>= await
          R.collapse results `shouldEqual` [
              R.Describe ["a", "b"],
              R.It "works" Success
            ]
        it "collapses groups into entries with shared describes" do
          results <- collect sharedDescribeTest >>= await
          R.collapse results `shouldEqual` [
              R.Describe ["a", "b"],
              R.It "works" Success,
              R.Describe ["a", "c"],
              R.It "also works" Success
            ]
        it "reports failed tests" do
          results <- collect failureTest >>= await
          R.collapse results `shouldEqual` [
            R.It "fails" (Failure (error "1 ≠ 2"))
          ]
        it "reports pending tests" do
          results <- collect pendingTest >>= await
          R.collapse results `shouldEqual` [
            R.Pending "is not written yet"
          ]
