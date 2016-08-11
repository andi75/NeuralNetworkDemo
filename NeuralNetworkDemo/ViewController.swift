//
//  ViewController.swift
//  NeuralNetworkDemo
//
//  Created by Andreas Umbach on 01.08.2016.
//  Copyright © 2016 Andreas Umbach. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var neuralNetView: NeuralNetView!
    
    @IBOutlet weak var situationChooser: UISegmentedControl!
    
    func updateNetwork()
    {
        switch(situationChooser.selectedSegmentIndex)
        {
        case 0:
            self.net = NeuralNet(numberOfInputNeurons: 3 /* bias plus two neurons */, numberOfHiddenLayers: 0, numberOfNeuronsInHiddenLayer: 0, numberOfOutputNeurons: 1)
        case 1:
            self.net = NeuralNet(numberOfInputNeurons: 4 /* bias plus three neurons */, numberOfHiddenLayers: 0, numberOfNeuronsInHiddenLayer: 0, numberOfOutputNeurons: 1)
        case 2:
            self.net = createUniversityNet()
        
        default:
            assert(false)
            self.net = nil
        }
        self.net!.print()
        self.neuralNetView.setNeedsDisplay()
    }
    
    func createUniversityNet() -> NeuralNet
    {
        let n = NeuralNet()
        // the neural net for the university testcase contains
        // 3 neurons in the input layer (neuron 0 is bias, so it
        // has no input weight)
        
        n.inputLayer.neurons.append( Neuron(inWeightCount: 0, outWeightCount: 3) )
        n.inputLayer.neurons.append( Neuron(inWeightCount: 1, outWeightCount: 3) )
        n.inputLayer.neurons.append( Neuron(inWeightCount: 1, outWeightCount: 3) )
        
        n.hiddenLayers.append( Layer() )
        n.hiddenLayers[0].neurons.append( Neuron(inWeightCount: 0, outWeightCount: 2) )
        n.hiddenLayers[0].neurons.append( Neuron(inWeightCount: 3, outWeightCount: 2) )
        n.hiddenLayers[0].neurons.append( Neuron(inWeightCount: 3, outWeightCount: 2) )
        n.hiddenLayers[0].neurons.append( Neuron(inWeightCount: 3, outWeightCount: 2) )
        
        n.outputLayer.neurons.append( Neuron(inWeightCount: 2, outWeightCount: 0) )
        n.outputLayer.neurons.append( Neuron(inWeightCount: 2, outWeightCount: 0) )
        
        return n
    }
    
    @IBAction func situationChanged(sender: UISegmentedControl) {
        updateNetwork()
    }
    
    @IBAction func trainPressed() {
        // lots of default values
        // let training = NeuralNetTraining(type: .SensorExample)
        var exampleType : NeuralNetTraining.ExampleType
        switch(situationChooser.selectedSegmentIndex)
        {
        case 0:
            exampleType = .SensorExample
        case 1:
            exampleType = .TrafficExample
        default:
            assert(false)
            return
        }
        let training = NeuralNetTraining(type: exampleType)

        training.train(self.net!)
        self.net!.print()
        training.printOutput(self.net!)
        self.neuralNetView.setNeedsDisplay()
    }

    @IBAction func randomizePressed() {
        self.net!.randomize()
        self.net!.print()
        self.neuralNetView.setNeedsDisplay()
    }
    
    var net : NeuralNet?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.neuralNetView.viewController = self
        
        updateNetwork()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

