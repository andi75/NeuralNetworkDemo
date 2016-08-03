//
//  Layer.swift
//  NeuralNetworkDemo
//
//  Created by Andreas Umbach on 01.08.2016.
//  Copyright © 2016 Andreas Umbach. All rights reserved.
//

import Foundation

class Layer
{
    var neurons : [Neuron]
    
    init()
    {
        neurons = [Neuron]()
    }
    
    init(neuronCount : Int)
    {
        neurons = [Neuron]()
        for _ in 0..<neuronCount
        {
            neurons.append( Neuron() )
        }
    }
    
    init(neuronCount : Int, inWeightCount : Int, outWeightCount: Int)
    {
        neurons = [Neuron]()
        for _ in 0..<neuronCount
        {
            neurons.append( Neuron(inWeightCount: inWeightCount, outWeightCount: outWeightCount) )
        }
    }
    
    func randomize()
    {
        for n in neurons{
            n.randomize()
        }
    }
    
    func print()
    {
        Swift.print("Neurons: \(neurons.count)")
        for n in neurons
        {
            n.print()
        }
    }
}