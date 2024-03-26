extends UnitTest

func test_generate_seed():
    return run_cases_b64(
        func(case):
            var kp = GDSodiumSign.generate_keypair(case[0])
            return kp.public_key == case[1],
        [
            ['MDEyMzQ1Njc4OUFCQ0RFRjAxMjM0NTY3ODlBQkNERUY=',
             'FO75iv9qq52Nt4dNecnpa+UdIVj3+xHV/34IvMAf2k8='],
            ['AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=',
             'O2onvM62pC1io6jQKm8Nc2UyFXcd4kOmOsBIoYtZ2ik='],
        ]
    )
