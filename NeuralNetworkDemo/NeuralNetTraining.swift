//
//  NeuralNetTraining.swift
//  NeuralNetworkDemo
//
//  Created by Andreas Umbach on 01.08.2016.
//  Copyright © 2016 Andreas Umbach. All rights reserved.
//

import Foundation

class NeuralNetTraining
{
    enum ExampleType { case SensorExample, TrafficExample }
    init(type: ExampleType)
    {
        switch(type)
        {
        case .SensorExample:
            maxEpochCount = 10
            targetError = 0.002
            learningRate = 1.0
            trainingType = .PERCEPTRON
            activationFunctionType = .STEP
            
            trainSets = [
                [ 1, 0, 0 ],
                [ 1, 0, 1 ],
                [ 1, 1, 0 ],
                [ 1, 1, 1 ]
            ]
            desiredResults = [ 0, 0, 0, 1 ]
        case .TrafficExample:
            maxEpochCount = 10
            targetError = 0.0001
            learningRate = 0.5
            trainingType = .ADALINE
            activationFunctionType = .LINEAR
            
            trainSets = [
                [1.0, 0.98, 0.94, 0.95 ],
                [1.0, 0.60, 0.60, 0.85 ],
                [1.0, 0.35, 0.15, 0.15 ],
                [1.0, 0.25, 0.30, 0.98 ],
                [1.0, 0.75, 0.85, 0.91 ],
                [1.0, 0.43, 0.57, 0.87 ],
                [1.0, 0.05, 0.06, 0.01 ],
            ]
            desiredResults = [ 0.80, 0.59, 0.23, 0.45, 0.74, 0.63, 0.10 ]
        }
    }
    
    var maxEpochCount : Int
    var targetError : Double
    var learningRate : Double
    var meanSquareError = [Double]()

    enum ActivationFunctionType { case STEP, LINEAR, SIGLOG, HYPERTAN }
    enum TrainingType { case PERCEPTRON, ADALINE }
    
    var trainingType : TrainingType
    var activationFunctionType : ActivationFunctionType
    
    /** each "Train Set" is an array of Doubles */
    var trainSets : [ [Double] ]?
    /** each "Train Set" should output the value stored in desiredResults */
    var desiredResults : [Double]?
    
    /** Trains the neural Network n. This currently assumes that all neurons have only one input weight. Hidden Layers are not supported yet */
    func train(n : NeuralNet)
    {
        self.meanSquareError.removeAll()
        // meanSquareError.removeAll()
        for j in 0..<maxEpochCount
        {
            var mse : Double = 0
            for i in 0..<trainSets!.count
            {
                let set = self.trainSets![i]
                let result = desiredResults![i]
                
                let netValue = getNetValue(n, set: set)
                
                let estimatedOutput = self.activationFunction(netValue)
                let error = (result - estimatedOutput)
                // Swift.print("error for set \(i): \(error)")
                if( abs(error) > self.targetError)
                {
                    self.teachNeurons(trainSet: set, net: n, netValue: netValue, error: error)
                }
                mse += pow(error, 2)
            }
            self.meanSquareError.append(mse / Double(trainSets!.count))
            Swift.print("mean Square Error for epoch \(j): \(meanSquareError.last!)")
        }
    }
    
    func getNetValue(n : NeuralNet, set : [Double]) -> Double
    {
        var netValue : Double = 0
        
        // some assertions:
        assert(set.count == n.inputLayer.neurons.count)
        
        for j in 0..<set.count
        {
            let weightIn = n.inputLayer.neurons[j].weightsIn[0]
            netValue += weightIn * set[j]
        }
        return netValue
    }
    
    func printOutput(n : NeuralNet)
    {
        for i in 0..<trainSets!.count
        {
            let set = self.trainSets![i]
            let result = desiredResults![i]
            
            let netValue = self.getNetValue(n, set: set)
            let estimatedOutput = self.activationFunction(netValue)
            let error = (result - estimatedOutput)
            Swift.print("error for set \(i): \(error)")

        }
    }
    
    func calcNewWeight(oldWeight oldWeight: Double, trainSample: Double, netValue: Double, error: Double) -> Double
    {
        switch(self.trainingType)
        {
        case .ADALINE:
            return oldWeight + self.learningRate * error * trainSample * self.derivativeActivationFunction( netValue )
        case .PERCEPTRON:
            return oldWeight + self.learningRate * error * trainSample
        }
    }

    func teachNeurons(trainSet trainSet: [Double], net: NeuralNet, netValue: Double, error: Double)
    {
        for i in 0..<net.inputLayer.neurons.count
        {
            let oldWeight = net.inputLayer.neurons[i].weightsIn[0]
            let newWeight = self.calcNewWeight(oldWeight: oldWeight, trainSample: trainSet[i], netValue: netValue, error: error)
            
            net.inputLayer.neurons[i].weightsIn[0] = newWeight
        }
    }
    
    func activationFunction(x : Double) -> Double
    {
        switch(self.activationFunctionType)
        {
        case .STEP: return (x >= 0.0) ? 1.0 : 0.0
        case .LINEAR: return x
        case .SIGLOG: return 1.0 / (1.0 + exp(-x))
        case .HYPERTAN: return tanh(x)
        }
    }

    func derivativeActivationFunction(x : Double) -> Double
    {
        switch(self.activationFunctionType)
        {
        case .STEP: return 1
        case .LINEAR: return 1
        case .SIGLOG: return x * (1 - x)
        case .HYPERTAN: return 1 / pow(cosh(x), 2)
        }
    }
    
}