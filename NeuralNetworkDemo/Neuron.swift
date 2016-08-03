//
//  Neuron.swift
//  NeuralNetworkDemo
//
//  Created by Andreas Umbach on 01.08.2016.
//  Copyright © 2016 Andreas Umbach. All rights reserved.
//

import Foundation

class Neuron
{
    var weightsIn : [Double]
    var weightsOut : [Double]

    init()
    {
        self.weightsIn = [ 0 ]
        self.weightsOut = [ 0 ]
    }
    
    init(inWeightCount inWeightCount : Int, outWeightCount : Int)
    {
        self.weightsIn = [Double](count: inWeightCount, repeatedValue: 0.0)
        self.weightsOut = [Double](count: outWeightCount, repeatedValue: 0.0)
    }
    
    func print()
    {
        Swift.print("weights in: \(weightsIn.count)")
        for w in weightsIn
        {
            Swift.print(w)
        }
        Swift.print("weights out: \(weightsOut.count)")
        for w in weightsOut
        {
            Swift.print(w)
        }
    }
    
    func randomize()
    {
        for i in 0..<weightsIn.count
        {
            weightsIn[i] = Double(rand()) / Double(RAND_MAX)
        }
        for i in 0..<weightsOut.count
        {
            weightsOut[i] = Double(rand()) / Double(RAND_MAX)
        }    }
}